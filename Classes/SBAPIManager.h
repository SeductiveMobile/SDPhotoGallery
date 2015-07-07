//
//  AuthAPIClient.h
//  TezWay
//
//  Created by Богдан on 18.12.14.
//  Copyright (c) 2014 seductive.com.ua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"

@interface SBAPIManager : AFHTTPRequestOperationManager

- (void)setUsername:(NSString *)username andPassword:(NSString *)password;

+ (SBAPIManager *)sharedManager;

@end



@interface MMSessionManager : AFHTTPSessionManager

/**
 A shared instance of the AFHTTPSessionManager configured for the foursquare API. This instance of
 the session manager is intended to be used as an example for the AFMMRecordResponseSerializer, and
 will be configured with that response serializer such that it returns MMRecord subclasses in the
 response object.
 */
+ (instancetype)sharedClient;


@end
