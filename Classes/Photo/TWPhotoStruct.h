//
//  TWPhotoStruct.h
//  Tezway
//
//  Created by Bohdan on 12.06.15.
//  Copyright (c) 2015 seductive.com.ua. All rights reserved.
//

#import "JSONModel.h"

#define timeAnimationImageToCellBeforeAppearing 0.5

@protocol TWPhotoStruct <NSObject>

@end

@interface TWPhotoStruct : JSONModel

@property (nonatomic, strong) NSString * photoID;
@property (nonatomic, strong) NSString * photoName;
@property (nonatomic, assign) BOOL isMain;
@property (nonatomic, strong) NSString * contentSmall;
@property (nonatomic, strong) NSString * contentMedium;
@property (nonatomic, strong) NSString * contentLarge;

// FOR ANIMATION EFFECT
@property (nonatomic, assign) BOOL isNeedPauseBeforeApearing;
@property (nonatomic, strong) UIImage <Optional> * placeholderImage;


-(NSString *) getSmallPhotoURL;
-(NSString *) getMediumPhotoURL;
-(NSString *) getLargePhotoURL;
-(NSURL *) getBrowserURL;

@end
