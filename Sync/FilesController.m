//
//  FilesController.m
//  Sync
//
//  Created by Dan McGrady on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilesController.h"
#import "UsersController.h"

@implementation FilesController

- (id)init {
  self = [super init];
  if (self) {
    NSFileManager *fileManager= [NSFileManager defaultManager]; 
    BOOL isDir;
    
    // Create discuss.io folder
    NSString *directory = [NSHomeDirectory() stringByAppendingPathComponent:@"Discuss.io"];
    if(![fileManager fileExistsAtPath:directory isDirectory:&isDir])
      if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL])
        NSLog(@"Error: Create folder failed %@", directory);
    
    // Create uploaded folder
    NSString *uploadDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Discuss.io/Uploaded"];
    if(![fileManager fileExistsAtPath:uploadDir isDirectory:&isDir])
      if(![fileManager createDirectoryAtPath:uploadDir withIntermediateDirectories:YES attributes:nil error:NULL])
        NSLog(@"Error: Create folder failed %@", uploadDir);
  }
  return self;
}

- (void)awakeFromNib
{
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(openWebBrowser:)
   name:@"endUploadFile"
   object:nil];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(copyToClipboard:)
   name:@"endUploadFile"
   object:nil];
  
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(moveFileToUploaded:)
   name:@"endUploadFile"
   object:nil];
}

- (IBAction) openDFolder: (id) sender {
  NSString *directory = [NSHomeDirectory() stringByAppendingPathComponent:@"Discuss.io"];
  NSURL *fileURL = [NSURL fileURLWithPath: directory];
  [[NSWorkspace sharedWorkspace] openURL: fileURL]; 
}

- (IBAction) launchWebsite: (id) sender {
  NSString *fullUrl = [NSString stringWithFormat: @"http://localhost:3000/api_login/%@", [UsersController tokenValue]];
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:fullUrl]];
}

- (BOOL)writeToPasteBoard:(NSString *)stringToWrite
{
  NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
  [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
  return [pasteBoard setString:stringToWrite forType:NSStringPboardType];
}

- (void)openWebBrowser:(NSNotification *) notification
{
  NSDictionary *userInfo = notification.userInfo;
  if ([[UsersController browserValue] intValue] == 1) {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[userInfo objectForKey:@"fullUrl"]]];
  }
}

- (void)copyToClipboard:(NSNotification *) notification
{
  NSDictionary *userInfo = notification.userInfo;
  if ([[UsersController pasteValue] intValue] == 1) {
    [self writeToPasteBoard:[userInfo objectForKey:@"fullUrl"]];
  }
}

- (void)moveFileToUploaded:(NSNotification *) notification
{
  NSDictionary *userInfo = notification.userInfo;
  NSString *file = [userInfo objectForKey:@"file"];
  NSString *path = [userInfo objectForKey:@"path"];
  NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
  NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, file];
  NSString *destPath = [NSString stringWithFormat:@"%@/Uploaded/%@", path, file];

  // copy file to uploaded path
  [[NSFileManager defaultManager] copyItemAtPath:filePath 
                                          toPath:destPath 
                                           error:nil];
  // delete original file
  [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                               source:path destination:trashDir 
                                                files:[NSArray arrayWithObject:file] 
                                                  tag:nil];
}

@end
