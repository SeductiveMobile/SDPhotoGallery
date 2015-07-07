//
//  TWPhotoStruct.m
//  Tezway
//
//  Created by Bohdan on 12.06.15.
//  Copyright (c) 2015 seductive.com.ua. All rights reserved.
//

#import "TWPhotoStruct.h"
#import "TWConstantsValues.h"

@implementation TWPhotoStruct

-(NSString *) getSmallPhotoURL {
    return self.contentSmall;
}

-(NSString *) getMediumPhotoURL {
    return self.contentMedium;
}

-(NSString *) getLargePhotoURL {
    return self.contentLarge;
}

-(NSURL *) getBrowserURL {
    return [NSURL URLWithString:[self getLargePhotoURL]];
}

+(BOOL)propertyIsOptional: (NSString *) propertyName {
    if ([propertyName isEqualToString:@"isNeedPauseBeforeApearing"]) {
        return YES;
    }
    return [super propertyIsOptional:propertyName];
}

@end
