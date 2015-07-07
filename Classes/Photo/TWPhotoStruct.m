//
//  TWPhotoStruct.m
//  Tezway
//
//  Created by Bohdan on 12.06.15.
//  Copyright (c) 2015 seductive.com.ua. All rights reserved.
//

#import "TWPhotoStruct.h"
#import "ConstantsValues.h"

@implementation TWPhotoStruct

-(NSString *) getSmallPhotoURL {
    return [NSString stringWithFormat:@"%@%@", kTWProductionSiteURL, self.contentSmall];
}

-(NSString *) getMediumPhotoURL {
    return [NSString stringWithFormat:@"%@%@", kTWProductionSiteURL,  self.contentMedium];
}

-(NSString *) getLargePhotoURL {
    return [NSString stringWithFormat:@"%@%@", kTWProductionSiteURL, self.contentLarge];
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
