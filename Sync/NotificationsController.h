//
//  NotificationsController.h
//  Sync
//
//  Created by Dan McGrady on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl-withInstaller/Growl.h>

@interface NotificationsController : NSObject <GrowlApplicationBridgeDelegate> {}
  + (NotificationsController *) sharedController;
  + (BOOL) growlDetected;
  - (void) showGrowlWithTitle: (NSString *) title message: (NSString *) message;
  - (NSData *) growlIcon;
@end