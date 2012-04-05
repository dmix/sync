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

@interface DAppDelegate : NSObject <NSApplicationDelegate> {
  IBOutlet NSMenu *statusMenu;
  NSStatusItem *statusItem;
  
}

@property (nonatomic, retain) IBOutlet NSMenu *statusMenu;
@property (nonatomic, retain) NSStatusItem *statusItem;

- (void)updateStatusMenu;
- (void)startWatching;
- (IBAction)showAbout:(id)sender;

@end