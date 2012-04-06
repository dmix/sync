#import "SCEvents.h"
#import "SCEvent.h"
#import "DApi.h"
#import "AFJSONRequestOperation.h"
#import "JSONKit.h"

#import "WatchController.h"
#import "UsersController.h"

static NSString *SCEventsDownloadsDirectory = @"Discuss.io";

@implementation WatchController

@synthesize _currentFiles;

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
    [self newFileDetect:watchPath];
  }
}

- (void)newFileDetect:(NSString *)watchPath
{
  NSLog(@"NEW FILE EVENT (FILETYPE NOT FILTERED)");

  // return list of current dir
  NSArray *filelist = [self filesIn:watchPath];
  NSArray *uniqueFiles = [self uniqueFilesFom:filelist:self.currentFiles];

  NSUInteger i;
  NSUInteger countr = [uniqueFiles count];
  for (i = 0; i < countr; i++) {
    // Retrieve the new file name
    NSString *newFile = [uniqueFiles objectAtIndex: i];      
    
    // Send start notification
    NSString *uploadingText = [NSString stringWithFormat:@"Uploading file: %@", newFile];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:uploadingText forKey:@"uploadingText"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startUploadFile" object:nil userInfo:userInfo];

    // Upload the file
    [self uploadFile:watchPath:newFile];

    // Add new file to currentFiles array
    [self.currentFiles addObject:newFile];
  }
}

- (void)uploadFile:(NSString *)path:(NSString *)file {
  NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, file];
  NSString *mimeType = [NSString stringWithFormat:@"image/%@", @"png"];
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
    NSLog(@"FINISHED UPLOADING");

    // retrieve full url of the newly uploaded file
    NSDictionary *resultsDictionary = [operation.responseString objectFromJSONString];
    NSString *fullUrl = [NSString stringWithFormat:@"http://localhost:3000/app/documents/%@", [resultsDictionary valueForKeyPath:@"id"]];

    // Send end file upload notification
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: file, @"file", path, @"path", fullUrl, @"fullUrl", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"endUploadFile" object:nil userInfo:userInfo];
  } failure:nil];

  // Add file upload to queue
  NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
  [queue addOperation:operation];
}

#pragma mark -

- (void)dealloc
{
	[_events release], _events = nil;
  [_currentFiles release];
	[super dealloc];
}

@end