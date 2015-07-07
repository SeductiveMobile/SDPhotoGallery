//
//  CredentialStore.h
//  TezWay
//
//  Created by Богдан on 18.12.14.
//  Copyright (c) 2014 seductive.com.ua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialStore : NSObject

+ (BOOL)isLoggedIn;
+ (void)clearSavedCredentials;
+ (NSString *)authToken;
+ (void)setAuthToken:(NSString *)authToken;

+ (void)clearSavedTempCredentials;
+ (void)setTempAuthToken:(NSString *)authToken;
+ (NSString *)tempAuthToken;

@end
