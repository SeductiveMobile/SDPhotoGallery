//
//  AuthAPIClient.m
//  TezWay
//
//  Created by Богдан on 18.12.14.
//  Copyright (c) 2014 seductive.com.ua. All rights reserved.
//

#import "SBAPIManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "ConstantsValues.h"

@implementation SBAPIManager

#pragma mark - Methods

- (void)setUsername:(NSString *)username andPassword:(NSString *)password
{
    [self.requestSerializer clearAuthorizationHeader];
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    
}


#pragma mark - Initialization

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if(!self)
        return nil;
    
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    return self;
}

#pragma mark - Singleton Methods

+ (SBAPIManager *)sharedManager
{
    static dispatch_once_t pred;
    static SBAPIManager *_sharedManager = nil;
    
    dispatch_once(&pred, ^{ _sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:kTWProductionSiteURL]]; });
    return _sharedManager;
}

@end









@implementation MMSessionManager

+ (instancetype)sharedClient {
    static MMSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kTWProductionSiteURL]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone]];
    });
    
    return _sharedClient;
}


@end