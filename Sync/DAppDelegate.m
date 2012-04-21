#import "DAppDelegate.h"
#import "WatchController.h"
#import "UsersController.h"
#import "NotificationsController.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "Reachability.h"

@implementation DAppDelegate

@synthesize statusMenu;
@synthesize statusItem;
@synthesize watcher;
@synthesize blockLabel = _blockLabel;

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [NSThread detachNewThreadSelector:@selector(startWatching)
                           toTarget:self
                         withObject:nil];

  [[NSNotificationCenter defaultCenter] addObserver: self
                                        selector: @selector(reachabilityChanged:)
                                        name: kReachabilityChangedNotification
                                        object: nil];

  hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
	[hostReach startNotifier];
	
  internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
  
  wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
  NSLog(@"rchanged");
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
  NetworkStatus netStatus = [curReach currentReachabilityStatus];
  BOOL connectionRequired= [curReach connectionRequired];
  NSString* statusString= @"";
  switch (netStatus)
  {
    case NotReachable:
    {
      [self isNotReachable];
      //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
      connectionRequired= NO;  
      break;
    }      
    case ReachableViaWWAN:
    {
      [self isReachable];
      break;
    }
    case ReachableViaWiFi:
    {
      [self isReachable];
      break;
    }
  }
  if (connectionRequired)
  {
    statusString= [NSString stringWithFormat: @"%@, Connection Required", statusString];
  }
}

- (void)isReachable
{
  if ([UsersController tokenValue] == @"") {
    [progressItem setTitle:@"Please log in"];
    self.statusItem.image = [NSImage imageNamed:@"grey.png"];
    watcher._disableWatcher = YES;
  }
  else {
    [progressItem setTitle:@"All files uploaded"];
    self.statusItem.image = [NSImage imageNamed:@"app.gif"];
    watcher._disableWatcher = NO;
  }
}

- (void)isNotReachable
{
  [progressItem setTitle:@"No internet connectivity"];
  self.statusItem.image = [NSImage imageNamed:@"grey.png"];
  watcher._disableWatcher = YES;
}


- (void)startWatching
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  watcher = [[[WatchController alloc] init] autorelease];
  NSArray *filesArray = [watcher filesIn:@"/Users/dmix/Discuss.io"];
  NSMutableArray *mutaFilesArray = [[filesArray copy] autorelease];
  [watcher setCurrentFiles:mutaFilesArray];
  [watcher startEventListener];

  [[NSRunLoop currentRunLoop] run];
  [pool release];
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(startUploadFile:)
   name:@"startUploadFile"
   object:nil ];

  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(endUploadFile:)
   name:@"endUploadFile"
   object:nil ];

  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(loggedIn:)
   name:@"loggedIn"
   object:nil ];

  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(loggedOut:)
   name:@"loggedOut"
   object:nil ];
  
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength]; 
  [self.statusItem setMenu:self.statusMenu];
  [self.statusItem setHighlightMode:YES];
  NSImage *menuImage = [NSImage imageNamed:@"app.png"];
  [menuImage setTemplate:YES];
  [self.statusItem setImage:menuImage];
}

- (IBAction)showAbout:(id)sender
{
	[NSApp orderFrontStandardAboutPanel:self];
}

- (void)startUploadFile:(NSNotification *) notification
{
  NSDictionary *userInfo = notification.userInfo;
  NSString *origString = [userInfo objectForKey:@"uploadingText"];
  const int clipLength = 30;
  if([origString length] > clipLength)
  {
    origString = [NSString stringWithFormat:@"%@...",[origString substringToIndex:clipLength]];
  }
  [progressItem setTitle:origString];
  self.statusItem.image = [NSImage imageNamed:@"green.png"];
}

- (void)endUploadFile:(NSNotification *) notification
{
  [progressItem setTitle:@"All files uploaded"];
  self.statusItem.image = [NSImage imageNamed:@"app.gif"];
}

- (void)loggedIn:(NSNotification *) notification
{
  [progressItem setTitle:@"All files uploaded"];
  self.statusItem.image = [NSImage imageNamed:@"app.gif"];
  watcher._disableWatcher = NO;
}

- (void)loggedOut:(NSNotification *) notification
{
  [progressItem setTitle:@"Please log in"];
  self.statusItem.image = [NSImage imageNamed:@"grey.png"];
  watcher._disableWatcher = YES;
}

- (void)dealloc
{
  [statusItem release];
  [statusMenu release];
  [super dealloc];
}

@end