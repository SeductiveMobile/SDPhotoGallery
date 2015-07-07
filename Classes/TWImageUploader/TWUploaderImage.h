//
//  TWUploaderImage.h
//  Tezway
//
//  Created by Bohdan on 16.06.15.
//  Copyright (c) 2015 seductive.com.ua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWPhotosBase.h"

@interface TWUploaderImage : UIView

typedef NS_ENUM(NSUInteger, TWUploadImageMaskType) {
    TWUploadImageMaskTypeNone = 1,  // allow user interactions while HUD is displayed
    TWUploadImageMaskTypeClear,     // don't allow user interactions
    TWUploadImageMaskTypeBlack,     // don't allow user interactions and dim the UI in the back of the HUD
    TWUploadImageMaskTypeGradient   // don't allow user interactions and dim the UI with a a-la-alert-view background gradient
};


// STEP 1
+(void)uploadImage:(UIImage *)image withParams:(NSDictionary *)parameters;
+(void)uploadImage:(UIImage *)image withParams:(NSDictionary *)parameters animationAfterLoadingToIndexPath:(NSIndexPath *)indexPath forGalery:(TWPhotosBase *)galeryVC;

// OPTIONAL
+(void) setSuccessBlock:(void (^) ())successHandler;
+(void) setFailureBlock:(void (^) (NSError *error))failureHandler; // IF NOT OVERRIDE, USER WILL SEE ALERT WITH REQUEST OF REPEATING UPLOADING

@end
