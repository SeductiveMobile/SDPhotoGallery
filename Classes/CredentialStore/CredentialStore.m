//
//  CredentialStore.m
//  TezWay
//
//  Created by Богдан on 18.12.14.
//  Copyright (c) 2014 seductive.com.ua. All rights reserved.
//

#import "CredentialStore.h"
#import "SSKeychain.h"

#define SERVICE_NAME @"TezTaxi-AuthClient"
#define AUTH_TOKEN_KEY @"auth_token"
#define TEMP_AUTH_TOKEN_KEY @"temp_auth_token"

@implementation CredentialStore

+ (BOOL)isLoggedIn {
    return [self authToken] != nil;
}

+ (void)clearSavedCredentials {
    [self setAuthToken:nil];
}

+ (NSString *)authToken {
    return [self secureValueForKey:AUTH_TOKEN_KEY];
}

+ (void)setAuthToken:(NSString *)authToken {
    [self setSecureValue:authToken forKey:AUTH_TOKEN_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"token-changed" object:self];
}

+ (void)setSecureValue:(NSString *)value forKey:(NSString *)key {
    if (value) {
        [SSKeychain setPassword:value
                     forService:SERVICE_NAME
                        account:key];
    } else {
        [SSKeychain deletePasswordForService:SERVICE_NAME account:key];
    }
}

+ (NSString *)secureValueForKey:(NSString *)key {
    return [SSKeychain passwordForService:SERVICE_NAME account:key];
}

#pragma mark -
#pragma mark Temp For non Activated accounts

+ (void)clearSavedTempCredentials {
    [self setTempAuthToken:nil];
}

+ (void)setTempAuthToken:(NSString *)authToken {
    [self setSecureValue:authToken forKey:TEMP_AUTH_TOKEN_KEY];
}

+ (NSString *)tempAuthToken {
    return [self secureValueForKey:TEMP_AUTH_TOKEN_KEY];
}





@end
