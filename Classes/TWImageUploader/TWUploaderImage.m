//
//  TWUploaderImage.m
//  Tezway
//
//  Created by Bohdan on 16.06.15.
//  Copyright (c) 2015 seductive.com.ua. All rights reserved.
//

#import "TWUploaderImage.h"
#import "AFHTTPRequestOperationManager.h"
#import "SBAPIManager.h"
#import <FXBlurView/FXBlurView.h>
#import "UIBAlertView.h"
#import "TWPhotoStruct.h"
#import "UIGalleryToServer.h"


@interface TWUploaderImage ()


@property (strong, nonatomic) UIImage * uploadingImage;
@property (strong, nonatomic) NSDictionary * parameters;

@property (strong, nonatomic) UIView * windowWithProgressInfo;
@property (strong, nonatomic) UILabel * progressLabel;
@property (strong, nonatomic) UIImageView * imageBackground;
@property (strong, nonatomic) FXBlurView * blurView;
@property (strong, nonatomic) UIView * blackView;
@property (nonatomic, readwrite) TWUploadImageMaskType maskType;

// ANIMATION AFTER UPLOADING FOR GALERY
@property (strong, nonatomic) TWPhotosBase * galeryVC;
@property (strong, nonatomic) NSIndexPath * indexPath;
@property (assign, nonatomic) BOOL isAnimated;

// HANDLERS FOR UPLOADING
@property (nonatomic, copy) void (^successHandler)();
@property (nonatomic, copy) void (^failureHandler)(NSError *error);

@end

#define sideKoef 0.4f
#define sideZoomedKoef 0.8f
#define sideminKoef 0.0f
#define cornerRadiusForWindowProgressInfo 12.0f

@implementation TWUploaderImage

+ (TWUploaderImage * ) sharedInstance {
    
    static dispatch_once_t pred;
    static TWUploaderImage *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[TWUploaderImage alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        shared.backgroundColor = [UIColor clearColor];
        shared.maskType = TWUploadImageMaskTypeGradient;
    });
    
    return shared;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

#pragma mark -
#pragma mark MAIN uploading methods

+(void)uploadImage:(UIImage *)image withParams:(NSDictionary *)parameters animationAfterLoadingToIndexPath:(NSIndexPath *)indexPath forGalery:(TWPhotosBase *)galeryVC {
    [self sharedInstance].galeryVC = galeryVC;
    [self sharedInstance].indexPath = indexPath;
    [self uploadImage:image withParams:parameters];
    [self sharedInstance].isAnimated = YES;
}

+(void)uploadImage:(UIImage *)image withParams:(NSDictionary *)parameters {
    [self sharedInstance].isAnimated = NO;
    [self sharedInstance].parameters = parameters;
    [self sharedInstance].uploadingImage = image;
    [[self sharedInstance] showInterfaceUploading];
}


#pragma mark -
#pragma mark Blocks

+(void) setSuccessBlock:(void (^) ())successHandler {
    [self sharedInstance].successHandler = successHandler;
}

+(void) setFailureBlock:(void (^) (NSError *error))failureHandler {
    [self sharedInstance].failureHandler = failureHandler;
}


#pragma mark -
#pragma mark Creation UI

-(void) showInterfaceUploading {
    if(!self.superview){
        [[TWUploaderImage sharedInstance] createProgressInfo];
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        UIScreen *mainScreen = UIScreen.mainScreen;
        
        for (UIWindow *window in frontToBackWindows)
            if (window.screen == mainScreen && window.windowLevel == UIWindowLevelNormal) {
                [window addSubview:self];
                break;
            }
    } else {
        [self.superview bringSubviewToFront:self];
    }
    [self UIConfigurationBeforeShowing];
    [self show];
    [self uploadImageToServer];
}

-(void) createProgressInfo {
    self.windowWithProgressInfo = [[UIView alloc] initWithFrame:[self getFrameForWindowInfoWithSideKoef:sideZoomedKoef]];
    self.windowWithProgressInfo.backgroundColor = [UIColor grayColor];
    self.windowWithProgressInfo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.windowWithProgressInfo.layer.cornerRadius = cornerRadiusForWindowProgressInfo;
    
    self.windowWithProgressInfo.layer.masksToBounds = YES;
    self.windowWithProgressInfo.alpha = 0.0;
    self.windowWithProgressInfo.layer.shadowOffset = CGSizeMake(-15, 20);
    self.windowWithProgressInfo.layer.shadowRadius = 5;
    self.windowWithProgressInfo.layer.shadowOpacity = 0.5;
    
    [self.windowWithProgressInfo addSubview:[self createImageForBackground]];
    [self.windowWithProgressInfo addSubview:[self createBlackViewUnderImage]];
    [self.windowWithProgressInfo addSubview:[self createBlurView]];
    [self.windowWithProgressInfo addSubview:[self createProgressLabel]];
    [self addSubview:self.windowWithProgressInfo];
}

-(UIImageView *)createImageForBackground {
    CGRect imgFrame = [self getFrameForWindowInfoWithSideKoef:sideZoomedKoef];
    imgFrame.origin = CGPointMake(0, 0);
    self.imageBackground = [[UIImageView alloc] initWithFrame:imgFrame];
    self.imageBackground.contentMode = UIViewContentModeScaleAspectFill;
    self.imageBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return self.imageBackground;
}

-(UIView *)createBlackViewUnderImage {
    CGRect frame = [self getFrameForWindowInfoWithSideKoef:sideZoomedKoef];
    frame.origin = CGPointMake(0, 0);
    UIView * view = [[UIView alloc] initWithFrame:frame];
    [view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return view;
}

-(UILabel *)createProgressLabel {
    CGRect imgFrame = [self getFrameForWindowInfoWithSideKoef:sideZoomedKoef];
    imgFrame.origin = CGPointMake(0, 0);
    self.progressLabel = [[UILabel alloc] initWithFrame:imgFrame];
    [self.progressLabel setFont:[UIFont systemFontOfSize:30 weight:0.05]];
    self.progressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    return self.progressLabel;
}

-(FXBlurView *)createBlurView {
    CGRect imgFrame = [self getFrameForWindowInfoWithSideKoef:sideZoomedKoef];
    imgFrame.origin = CGPointMake(0, 0);
    self.blurView = [[FXBlurView alloc] initWithFrame:imgFrame];
    self.blurView.dynamic = NO;
    self.blurView.blurRadius = 5;
    self.blurView.tintColor = [UIColor blackColor];
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return self.blurView;
}

-(CGRect) getFrameForWindowInfoWithSideKoef:(float)koef {
    CGRect windowRect = [[UIScreen mainScreen] bounds];
    float side = (windowRect.size.height < windowRect.size.width)? windowRect.size.height : windowRect.size.width;
    side = side * koef;
    CGRect res = CGRectMake((windowRect.size.width - side) / 2, (windowRect.size.height - side) / 2, side, side);
    return res;
}


#pragma mark -
#pragma mark Presentation UI

-(void)UIConfigurationBeforeShowing {
    [self.windowWithProgressInfo setFrame:[self getFrameForWindowInfoWithSideKoef:sideZoomedKoef]];
    self.progressLabel.alpha = 0;
    self.progressLabel.text = @"0%";
    self.blurView.alpha = 1.0f;
    self.blackView.alpha = 1.0f;
    self.windowWithProgressInfo.layer.cornerRadius = cornerRadiusForWindowProgressInfo;
    [self.imageBackground setImage:self.uploadingImage];
}

-(void)UIConfigurationBeforeRepeating {
    self.progressLabel.text = @"0%";
}

-(void) show {
    self.blurView.dynamic = YES;
    [self setHidden:NO];
    [UIView animateWithDuration:0.2 animations:^{
        [self.windowWithProgressInfo setFrame:[self getFrameForWindowInfoWithSideKoef:sideKoef]];
        self.windowWithProgressInfo.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self setProgressAlpha:1.0];
    }];
}

-(void) setProgressAlpha:(float)alpha {
    [UIView animateWithDuration:0.2 animations:^{
        self.progressLabel.alpha = alpha;
    }];
}

-(void) hide {
    self.progressLabel.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.windowWithProgressInfo setFrame:[self getFrameForWindowInfoWithSideKoef:sideminKoef]];
    } completion:^(BOOL finished) {
        [self setHidden:YES];
        self.blurView.dynamic = NO;
        [self UIConfigurationBeforeShowing];
    }];
    self.successHandler = nil;
    self.failureHandler = nil;
}


-(void) hideToFrame:(CGRect)frame {
    self.progressLabel.alpha = 0;
    [UIView animateWithDuration:timeAnimationImageToCellBeforeAppearing animations:^{
        [self.windowWithProgressInfo setFrame:frame];
        self.blackView.alpha = 0.0f;
        self.blurView.alpha = 0.0f;
        self.windowWithProgressInfo.layer.cornerRadius = 0;
    } completion:^(BOOL finished) {
        [self setHidden:YES];
        self.blurView.dynamic = NO;
        [self UIConfigurationBeforeShowing];
    }];
    self.successHandler = nil;
    self.failureHandler = nil;
}

-(void)addCellForAnimationWithPhoto:(TWPhotoStruct *)photo {
    NSIndexPath * indexPath = self.indexPath;
    if (!indexPath) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    NSMutableArray * rows = self.galeryVC.dataSource[self.indexPath.section];
    [rows insertObject:photo atIndex:0];
    [self.galeryVC.collectionView insertItemsAtIndexPaths:@[indexPath]];
    [self.galeryVC showNoPhotoAlertIfNeeded];
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (self.maskType) {
        case TWUploadImageMaskTypeBlack: {
            
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            
            break;
        }
        case TWUploadImageMaskTypeGradient: {

            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGFloat freeHeight = CGRectGetHeight(self.bounds);
            
            CGPoint center = CGPointMake(CGRectGetWidth(self.bounds)/2, freeHeight/2);
            float radius = MIN(CGRectGetWidth(self.bounds) , CGRectGetHeight(self.bounds)) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            
            break;
        }
        default:
            break;
    }
}




#pragma mark -
#pragma mark Uploading Image


-(void) uploadImageToServer {
    NSData * imageData =  UIImageJPEGRepresentation(self.uploadingImage, 0.7);

    __weak typeof(self) weakSelf = self;

    [UIGalleryToServer uploadImageWithParams:nil url:@"" iamge:imageData success:^(id responseObject) {
        NSError *errorMessage;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&errorMessage];
        TWPhotoStruct * photo = [[TWPhotoStruct alloc] initWithDictionary:dict error:&errorMessage];
        photo.placeholderImage = weakSelf.uploadingImage;
        photo.isNeedPauseBeforeApearing = weakSelf.isAnimated;
        if (errorMessage) {
            [weakSelf errorHandelrWithError:errorMessage];
            return;
        }
        
        if (weakSelf.isAnimated) {
            [weakSelf animateImageToAppearingPositionWithPhoto:photo];
        } else if (weakSelf.successHandler) {
            weakSelf.successHandler();
            [weakSelf hide];
        } else {
            [weakSelf hide];
        }
    } failure:^(NSError *error) {
        [self errorHandelrWithError:error];
    } progress:^(float progressValue) {
        self.progressLabel.text = [NSString stringWithFormat:@"%0.0f %%", progressValue];
    }];
}

-(void)errorHandelrWithError:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    if (weakSelf.failureHandler) {
        [weakSelf hide];
        weakSelf.failureHandler(error);
    } else {
        [weakSelf requestUserToReuploadImageAgain];
    }
}


-(void)animateImageToAppearingPositionWithPhoto:(TWPhotoStruct *)photo {
    [self addCellForAnimationWithPhoto:photo];
    UICollectionView * cv = self.galeryVC.collectionView;
    UICollectionViewLayoutAttributes *attributes = [cv layoutAttributesForItemAtIndexPath:self.indexPath];
    CGRect cellRect = attributes.frame;
    CGRect cellFrameInSuperview = [cv convertRect:cellRect toView:self.window];
    
    // call handler befor we set nil it
    if (self.successHandler) {
        self.successHandler();
    }
    [self hideToFrame:cellFrameInSuperview];
}


-(void)requestUserToReuploadImageAgain {
    UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось загрузить фото, попробовать еще раз?" cancelButtonTitle:@"Отмена" otherButtonTitles:@"Да", nil];
    
    [alert showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL onCanceled) {
        if (onCanceled) {
            [self hide];
            return;
        }
        if(selectedIndex == 1) {
            [self UIConfigurationBeforeRepeating];
            [self uploadImageToServer];
        }
    }];
}


@end
