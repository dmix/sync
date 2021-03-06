//
//  DAppDelegate.h
//  Sync
//
//  Created by Dan McGrady on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCEvents.h"
#import "WatchController.h"
#import "Reachability.h"

@interface DAppDelegate : NSObject <NSApplicationDelegate> {
  IBOutlet NSMenu *statusMenu;
  NSStatusItem *statusItem;
  IBOutlet NSMenuItem *progressItem;
  WatchController *watcher;
  Reachability* hostReach;
  Reachability* internetReach;
  Reachability* wifiReach;
}

@property (nonatomic, retain) IBOutlet NSMenu *statusMenu;
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (assign, nonatomic) IBOutlet NSTextField * blockLabel;
@property (nonatomic, copy) WatchController *watcher;

- (void)startUploadFile:(NSNotification *) notification;
- (void)endUploadFile:(NSNotification *) notification;
- (void)startWatching;
- (void)isReachable;
- (void)isNotReachable;
- (void)loggedIn:(NSNotification *) notification;
- (void)loggedOut:(NSNotification *) notification;
- (IBAction)showAbout:(id)sender;

@end