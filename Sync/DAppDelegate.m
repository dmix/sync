#import "DAppDelegate.h"
#import "WatchController.h"
#import "NotificationsController.h"
#import "SCEvents.h"
#import "SCEvent.h"

@implementation DAppDelegate

@synthesize statusMenu;
@synthesize statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [NSThread detachNewThreadSelector:@selector(startWatching)
                           toTarget:self
                         withObject:nil];
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
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength]; 
  [self.statusItem setMenu:self.statusMenu];
  [self.statusItem setHighlightMode:YES];
//  [self.statusItem setTitle:@"discuss.io"];

  [self updateStatusMenu];
}

- (IBAction)showAbout:(id)sender
{
	[NSApp orderFrontStandardAboutPanel:self];
}

- (void)updateStatusMenu
{
  self.statusItem.image = [NSImage imageNamed:@"app.png"];
}

- (void)dealloc
{
  [statusItem release];
  [statusMenu release];
  [super dealloc];
}

@end