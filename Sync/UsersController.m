//
//  UsersController.m
//  Sync
//
//  Created by Dan McGrady on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//                          @"zpXNjmITjnwInML8LISV", @"api_token",

#import "UsersController.h"
#import "DApi.h"
#import "NotificationsController.h"

@implementation UsersController

+ (void)initialize {
  // Create a dictionary
  NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

  // Put defaults in the dictionary
  NSNumber *startupState = [NSNumber numberWithInt:1];
  [defaultValues setObject:startupState
                    forKey:@"DStartup"];
  NSNumber *browserState = [NSNumber numberWithInt:1];
  [defaultValues setObject:browserState
                    forKey:@"DBrowser"];
  NSNumber *pasteState = [NSNumber numberWithInt:1];
  [defaultValues setObject:pasteState
                    forKey:@"DPaste"];
  NSNumber *growlState = [NSNumber numberWithInt:1];
  [defaultValues setObject:growlState
                    forKey:@"DGrowl"];

  // Register the dictionary of defaults
  [[NSUserDefaults standardUserDefaults]
                   registerDefaults: defaultValues];

  NSLog(@"registered defaults: %@", defaultValues);
}

- (id)init {
  self = [super init];
  if (self) {
    [self logInWith:[UsersController loginValue]:[UsersController passwordValue]];  
  }
  return self;
}

- (void) loadFieldValues {
  [login setStringValue:[UsersController loginValue]];
  [password setStringValue:[UsersController passwordValue]];
}

+ (void)setLoginPassword:(NSString *)login:(NSString *)password:(NSString *)token {
  [[NSUserDefaults standardUserDefaults] setObject:login
                                            forKey:@"DLogin"];
  [[NSUserDefaults standardUserDefaults] setObject:password
                                            forKey:@"DPassword"];
  [[NSUserDefaults standardUserDefaults] setObject:token
                                            forKey:@"DToken"];
}

+ (NSString *)loginValue {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey:@"DLogin"];
}

+ (NSString *)passwordValue {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey:@"DPassword"];
}

+ (NSString *)tokenValue {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey:@"DToken"];
}

+ (NSNumber *)startupValue {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey:@"DStartup"];
}

+ (NSNumber *)pasteValue {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey:@"DPaste"];
}

+ (NSNumber *)browserValue {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey:@"DBrowser"];
}

+ (NSNumber *)growlValue {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey:@"DGrowl"];
}

- (IBAction) logIn: (id) sender {
	NSString *loginText	= [login stringValue];
	NSString *passwordText = [password stringValue];
  [status setStringValue:@"Authenticating..."];
  [self logInWith:loginText:passwordText];

  return;
}

- (void) logInWith:(NSString *)loginText:(NSString *)passwordText {
  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                          passwordText, @"user_session[password]",
                          loginText, @"user_session[login]",
                          nil];

  [[DApi sharedClient] postPath:@"/api/user_sessions" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSString *tokenText	= [responseObject valueForKeyPath:@"single_access_token"];
    NSLog(@"single_access_token: %@", tokenText);

    NotificationsController *growl = [NotificationsController sharedController];
    [growl showGrowlWithTitle: @"Discuss.io"
                      message: @"Logged in successfully"];

    [status setStringValue:[NSString stringWithFormat: @"Logged in as: %@", [responseObject valueForKeyPath:@"login"]]];
    [UsersController setLoginPassword:loginText:passwordText:tokenText];
  } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
    [status setStringValue:@"Password or email is incorrect"];
  }];
}

- (IBAction) changeLoginItem: (id) sender {
  NSNumber *state = [NSNumber numberWithInteger:[loginCheckbox state]];
  if ([state intValue] == 1) {
    [self addAppAsLoginItem];
  } else {
    [self deleteAppFromLoginItem];
  }
  [[NSUserDefaults standardUserDefaults] setObject:state
                                            forKey:@"DStartup"];
  NSLog(@"Login item changed %@", state);
}

- (IBAction) changeBrowser: (id) sender {
  NSNumber *state = [NSNumber numberWithInteger:[browserCheckbox state]];
  [[NSUserDefaults standardUserDefaults] setObject:state
                                             forKey:@"DBrowser"];
  NSLog(@"Browser changed %@", state);
}

- (IBAction) changePaste: (id) sender {
  NSNumber *state = [NSNumber numberWithInteger:[pasteCheckbox state]];
  [[NSUserDefaults standardUserDefaults] setObject:state
                                             forKey:@"DPaste"];
  NSLog(@"Paste changed %@", state);
}

- (IBAction) changeGrowl: (id) sender {
  NSNumber *state = [NSNumber numberWithInteger:[growlCheckbox state]];
  [[NSUserDefaults standardUserDefaults] setObject:state
                                            forKey:@"DGrowl"];
  NSLog(@"Growl changed %@", state);
}

-(void) addAppAsLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
  
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
  
	// Create a reference to the shared file list.
  // We are adding it to the current user only.
  // If we want to add it all users, use
  // kLSSharedFileListGlobalLoginItems instead of
  //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                          kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                 kLSSharedFileListItemLast, NULL, NULL,
                                                                 url, NULL, NULL);
		if (item){
			CFRelease(item);
    }
	}	
  
	CFRelease(loginItems);
}

-(void) deleteAppFromLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
  
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
  
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                          kLSSharedFileListSessionLoginItems, NULL);
  
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		int i = 0;
		for(i ; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray
                                                                  objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
		[loginItemsArray release];
	}
}
@end
