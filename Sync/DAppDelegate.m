#import "DAppDelegate.h"
#import "WatchController.h"
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
    NSLog(@"REACHABLE!");
  };
  
  reach.unreachableBlock = ^(Reachability*reach)
  {
    NSLog(@"UNREACHABLE!");
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
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[userInfo objectForKey:@"uploadingText"]
                                                action:nil keyEquivalent:@""]; 
  [item autorelease];
  [item setTarget:self];
  [statusMenu insertItem:item atIndex:0];
  [statusMenu update];
  self.statusItem.image = [NSImage imageNamed:@"green.png"];
}

- (void)endUploadFile:(NSNotification *) notification
{
  [statusMenu removeItemAtIndex:0];
  [statusMenu update];
  self.statusItem.image = [NSImage imageNamed:@"app.gif"];
}

- (void)dealloc
{
  [statusItem release];
  [statusMenu release];
  [super dealloc];
}

@end