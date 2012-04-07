#import "NotificationsController.h"
#import "UsersController.h"

@implementation NotificationsController

+ (NotificationsController *) sharedController {
  static NotificationsController *instance = nil;
  if (!instance) {
    instance = [[NotificationsController alloc] init];
  }
  return instance;
}

+ (BOOL) growlDetected {
  return [GrowlApplicationBridge isGrowlRunning];
}

- (id) init {
  self = [super init];
  if (self) {
    [GrowlApplicationBridge setGrowlDelegate: self];
  }
  return self;
}

- (void)awakeFromNib
{
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(startUploadFile:)
   name:@"startUploadFile"
   object:nil];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(endUploadFile:)
   name:@"endUploadFile"
   object:nil];

  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(loggedIn:)
   name:@"loggedIn"
   object:nil];
}

- (void)startUploadFile:(NSNotification *) notification
{
  NSDictionary *userInfo = notification.userInfo;
  [self showGrowlWithTitle: @"Discuss.io"
                   message: [userInfo objectForKey:@"uploadingText"]];
}

- (void)endUploadFile:(NSNotification *) notification
{
  NSDictionary *userInfo = notification.userInfo;
  [self showGrowlWithTitle: @"Discuss.io"
                   message: [NSString stringWithFormat:@"%@ has finished uploading", [userInfo objectForKey:@"file"]]];
}

- (void)loggedIn:(NSNotification *) notification
{
  [self showGrowlWithTitle: @"Discuss.io"
                   message: @"Logged in successfully"];
}

- (void) showGrowlWithTitle: (NSString *) title message: (NSString *) message {
  if ([[UsersController growlValue] intValue] == 1) {
    [GrowlApplicationBridge notifyWithTitle: title
                                description: message
                           notificationName: @"new_messages"
                                   iconData: [self growlIcon]
                                   priority: 0
                                   isSticky: NO
                               clickContext: nil];
  }
}

- (NSData *) growlIcon {
  static NSData *icon = nil;
  if (!icon) {
    icon = [[NSImage imageNamed: @"icon_app_32.png"] TIFFRepresentation];
  }
  return icon;
}

/* Dealloc method */
- (void) dealloc { 
  [super dealloc]; 
}
@end


