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
@synthesize blockLabel = _blockLabel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [NSThread detachNewThreadSelector:@selector(startWatching)
                           toTarget:self
                         withObject:nil];

  Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
  
  // set the blocks 
  reach.reachableBlock = ^(Reachability*reach)
  {
    if ([UsersController tokenValue] == @"") {
      [progressItem setTitle:@"Please log in"];
      self.statusItem.image = [NSImage imageNamed:@"grey.png"];
    }
    else {
      [progressItem setTitle:@"All files uploaded"];
      self.statusItem.image = [NSImage imageNamed:@"app.gif"];
    }
  };
  
  reach.unreachableBlock = ^(Reachability*reach)
  {
    [progressItem setTitle:@"No internet connectivity"];
    self.statusItem.image = [NSImage imageNamed:@"grey.png"];
  };
  
  [reach startNotifier];
}


- (void)startWatching
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  WatchController *controller = [[[WatchController alloc] init] autorelease];
  NSArray *filesArray = [controller filesIn:@"/Users/dmix/Discuss.io"];
  [controller setCurrentFiles:filesArray];
  [controller setupEventListener];

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
  [progressItem setTitle:[userInfo objectForKey:@"uploadingText"]];
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
}

- (void)loggedOut:(NSNotification *) notification
{
  [progressItem setTitle:@"Please log in"];
  self.statusItem.image = [NSImage imageNamed:@"grey.png"];
}

- (void)dealloc
{
  [statusItem release];
  [statusMenu release];
  [super dealloc];
}

@end