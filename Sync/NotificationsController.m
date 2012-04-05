//
//  NotificationsController.m
//  Sync
//
//  Created by Dan McGrady on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationsController.h"

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

- (void) showGrowlWithTitle: (NSString *) title message: (NSString *) message {
  [GrowlApplicationBridge notifyWithTitle: title
                              description: message
                         notificationName: @"new_messages"
                                 iconData: [self growlIcon]
                                 priority: 0
                                 isSticky: NO
                             clickContext: nil];
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


