//
//  UsersController.h
//  Sync
//
//  Created by Dan McGrady on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "NotificationsController.h"

@interface UsersController : NSObject
{
  IBOutlet NSTextField *status;
  IBOutlet NSTextField *login;
  IBOutlet NSTextField *password;
  IBOutlet NSButton *loginCheckbox;
  IBOutlet NSButton *browserCheckbox;
  IBOutlet NSButton *pasteCheckbox;
}

- (void)loadFieldValues;
+ (void)setLoginPassword:(NSString *)login:(NSString *)password:(NSString *)token;

+ (NSString *)loginValue;
+ (NSString *)passwordValue;
+ (NSString *)tokenValue;
+ (NSString *)startupValue;
+ (NSString *)pasteValue;
+ (NSString *)browserValue;

- (IBAction) logIn: (id) sender;
- (IBAction) changeLoginItem: (id) sender;
- (IBAction) changeBrowser: (id) sender;
- (IBAction) changePaste: (id) sender;

- (void)logInWith:(NSString *)loginText:(NSString *)passwordText;

- (void) addAppAsLoginItem;
- (void) deleteAppFromLoginItem;

@end
