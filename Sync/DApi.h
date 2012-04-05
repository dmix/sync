//
//  DApi.h
//  Sync
//
//  Created by Dan McGrady on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface DApi : AFHTTPClient
+ (DApi *)sharedClient;
@end