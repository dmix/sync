#import "WatchController.h"
#import "UsersController.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "UsersController.h"
#import "DApi.h"
#import "AFJSONRequestOperation.h"
#import "JSONKit.h"

static NSString *SCEventsDownloadsDirectory = @"Discuss.io";

@implementation WatchController

@synthesize _currentFiles;

- (id)init {
  self = [super init];
  if (self) {
    NSFileManager *fileManager= [NSFileManager defaultManager]; 
    BOOL isDir;

    // Create discuss.io folder
    NSString *directory = [NSHomeDirectory() stringByAppendingPathComponent:@"Discuss.io"];
    if(![fileManager fileExistsAtPath:directory isDirectory:&isDir])
      if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL])
        NSLog(@"Error: Create folder failed %@", directory);

    // Create uploaded folder
    NSString *uploadDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Discuss.io/Uploaded"];
    if(![fileManager fileExistsAtPath:uploadDir isDirectory:&isDir])
      if(![fileManager createDirectoryAtPath:uploadDir withIntermediateDirectories:YES attributes:nil error:NULL])
        NSLog(@"Error: Create folder failed %@", uploadDir);
    
  }
  return self;
}

- (IBAction) openDFolder: (id) sender {
  NSString *directory = [NSHomeDirectory() stringByAppendingPathComponent:@"Discuss.io"];
  NSURL *fileURL = [NSURL fileURLWithPath: directory];
  [[NSWorkspace sharedWorkspace] openURL: fileURL]; 
}

- (IBAction) launchWebsite: (id) sender {
  NSString *fullUrl = [NSString stringWithFormat: @"http://localhost:3000/api_login/%@", [UsersController tokenValue]];
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:fullUrl]];
}


/**
 * Add the current list of files in the watched directory to an instance variable
 */
- (void)setCurrentFiles:(NSArray *)newArray {
  
  if ( _currentFiles != newArray ) { 
    [_currentFiles release];
    _currentFiles = [newArray mutableCopy];
  }

  return;
}

/**
 * Sets up the event listener using SCEvents and sets its delegate to this controller.
 * The event stream is started by calling startWatchingPaths: while passing the paths
 * to be watched.
 */
- (void)setupEventListener
{
	if (_events) return;
    _events = [[SCEvents alloc] init];
    [_events setIgnoreEventsFromSubDirs:1];
    [_events setDelegate:self];
    
    NSMutableArray *paths = [NSMutableArray arrayWithObject:[NSHomeDirectory() stringByAppendingPathComponent:SCEventsDownloadsDirectory]];

	// Start receiving events
	[_events startWatchingPaths:paths];

	// Display a description of the stream
  // NSLog(@"%@", [_events streamDescription]);	
}

/**
 * Returns an array of images for a paticular directory
 */
- (NSArray *)filesIn:(NSString *)dir
{
  NSFileManager *filemgr;
  NSArray *filelist;
  
  filemgr = [NSFileManager defaultManager];
  filelist = [filemgr contentsOfDirectoryAtPath: dir error: nil];
  
  NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg' OR self ENDSWITH '.jpeg' OR self ENDSWITH '.gif' OR self ENDSWITH '.psd' OR self ENDSWITH '.png' OR self ENDSWITH '.ai'"];
  NSArray *filteredArray = [filelist filteredArrayUsingPredicate:fltr];
  
  return filteredArray;
}

/**
 * Compares the current directories with previous filelist state and returns an array of newly added files
 */
- (NSArray *)uniqueFilesFom:(NSArray *)arrayA:(NSArray *)arrayB
{
  NSMutableArray *uniqueArray;
  uniqueArray = [[NSMutableArray alloc] init];
  for (NSString *myObject in arrayA) {
    if (![arrayB containsObject:myObject]) {
      // File is unique
      NSLog (@"%@ ++", myObject);
      [uniqueArray addObject:myObject];
    }
  }

  // compare two arrays and return unique elements
  return uniqueArray;
  [uniqueArray release];
}

/**
 * This is the only method to be implemented to conform to the SCEventListenerProtocol.
 * As this is only an example the event received is simply printed to the console.
 *
 * @param pathwatcher The SCEvents instance that received the event
 * @param event       The actual event
 */
- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event
{
  // Retrieve watched path root folder
  NSString *watchPath = [pathWatcher.watchedPaths objectAtIndex:0];
  NSArray *dirs = [watchPath componentsSeparatedByString: @"/"];
  NSUInteger dirCount = [dirs count] - 1;
  NSString *watchFolder = [dirs objectAtIndex:dirCount];

  // Retrieve evented paths root folder
  NSArray *chunks = [event.eventPath componentsSeparatedByString: @"/"];
  NSUInteger count = [chunks count] - 1;
  NSString *folder = [chunks objectAtIndex:count];

  // If folder is root directory, execute code
  BOOL isPath = [folder isEqual:watchFolder];
  if (isPath && event.eventFlags == 120064) {
    NSLog(@"%@", @"NEW FILE EVENT (FILETYPE NOT FILTERED)");
    
    // return list of current dir
    NSArray *filelist = [self filesIn:watchPath];
    NSArray *uniqueFiles = [self uniqueFilesFom:filelist:self.currentFiles];

    NSUInteger i;
    NSUInteger countr = [uniqueFiles count];
    for (i = 0; i < countr; i++) {
      NSString *newFile = [uniqueFiles objectAtIndex: i]; 
      NotificationsController *growl = [NotificationsController sharedController];
      
      NSString *uploadingText = [NSString stringWithFormat:@"Uploading new file: %@", newFile];
      // Growl: Uploading file
      [growl showGrowlWithTitle: @"Discuss.io"
                        message: uploadingText];

      // Insert menu item: Uploading file
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:uploadingText 
                                                    action:nil keyEquivalent:@""]; 
      [item autorelease];
      [item setTarget:self];
      [statusMenu insertItem:item atIndex:0];

      [self uploadFile:watchPath:newFile];
      [self.currentFiles addObject:newFile];     // Add new file to currentFiles array
    }
  }
}

- (void)uploadFile:(NSString *)path:(NSString *)file {

  // Define file paths and types
  NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, file];
  NSString *destPath = [NSString stringWithFormat:@"%@/Uploaded/%@", path, file];
  NSString *mimeType = [NSString stringWithFormat:@"image/%@", @"png"];
  NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
  NSString *api_token = [UsersController tokenValue];

  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                          api_token, @"api_token",
                          nil];

  // Set up API request
  NSMutableURLRequest *request = [[DApi sharedClient] multipartFormRequestWithMethod:@"POST" 
                                                                                path:@"/api/documents.json" 
                                                                          parameters:params 
                                                           constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                                                             NSData *data= [NSData dataWithContentsOfFile:filePath];
                                                             [formData appendPartWithFileData:data 
                                                                                         name:@"file" 
                                                                                     fileName:file 
                                                                                     mimeType:mimeType];}];

  AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];

  // Print out upload progress to logger
  [operation setUploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
    NSLog(@"Sent %ld of %ld bytes", totalBytesWritten, totalBytesExpectedToWrite);
  }];

  // Success and failure blocks
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSDictionary *resultsDictionary = [operation.responseString objectFromJSONString];
    NSString *docId	= [resultsDictionary valueForKeyPath:@"id"];
    NSString *fullUrl = [NSString stringWithFormat:@"http://localhost:3000/app/documents/%@", docId];

    NotificationsController *growl = [NotificationsController sharedController];
    [growl showGrowlWithTitle: @"Discuss.io"
                      message: [NSString stringWithFormat:@"%@ has finished uploading", file]];

    NSLog(@"FINISHED UPLOADING");
//    [statusMenu removeItemAtIndex:0];

    // open web browser
    if ([[UsersController browserValue] intValue] == 1) {
      [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:fullUrl]];
    }

    // copy to clipboard
    if ([[UsersController pasteValue] intValue] == 1) {
      [self writeToPasteBoard:fullUrl];
    }

    // copy file to uploaded path
    [[NSFileManager defaultManager] copyItemAtPath:filePath 
                                            toPath:destPath 
                                             error:nil];
    // delete original file
    [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                 source:path destination:trashDir 
                                                  files:[NSArray arrayWithObject:file] 
                                                    tag:nil];
  } failure:nil];

  // Add file upload to queue
  NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
  [queue addOperation:operation];
}

- (BOOL) writeToPasteBoard:(NSString *)stringToWrite
{
  NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
  [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
  return [pasteBoard setString:stringToWrite forType:NSStringPboardType];
}

#pragma mark -

- (void)dealloc
{
	[_events release], _events = nil;
  [_currentFiles release];
	[super dealloc];
}

@end