//
//  FilesController.h
//  Sync
//
//  Created by Dan McGrady on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilesController : NSObject

- (IBAction) openDFolder: (id) sender;
- (IBAction) launchWebsite: (id) sender;
- (BOOL) writeToPasteBoard:(NSString *)stringToWrite;
- (void)openWebBrowser:(NSNotification *) notification;
- (void)copyToClipboard:(NSNotification *) notification;
- (void)moveFileToUploaded:(NSNotification *) notification;

@end
