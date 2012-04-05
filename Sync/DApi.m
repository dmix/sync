//
//  DApi.m
//  Sync
//
//  Created by Dan McGrady on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DApi.h"
#import "AFJSONRequestOperation.h"

NSString * const discussURL = @"http://localhost:3000/";

@implementation DApi

+ (DApi *)sharedClient {
  static DApi *_sharedClient = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:discussURL]];
  });
  
  return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
  self = [super initWithBaseURL:url];
  if (!self) {
    return nil;
  }
  
  [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
  [self setDefaultHeader:@"Accept" value:@"application/json"];  
  return self;
}

@end
