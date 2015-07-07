//
//  TXPhotoCVC.m
//  Tezway
//
//  Created by Bohdan on 12.06.15.
//  Copyright (c) 2015 seductive.com.ua. All rights reserved.
//

#import "TXPhotoCVC.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIBAlertView.h"

@interface TXPhotoCVC()


@property (nonatomic, copy) void (^deleteBlock)();

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightDeleteButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintWidthDeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;


@end

#define deleteButtonSide 26

@implementation TXPhotoCVC

- (void)awakeFromNib {
    self.deleteButton.layer.masksToBounds = YES;
    self.deleteButton.layer.cornerRadius = deleteButtonSide / 2;
}

-(void) fillCellWithPhoto:(TWPhotoStruct *) photo deleteAction:(void (^) ())deleteBlock {
    self.deleteBlock = deleteBlock;
    [self fillCellWithPhoto:photo];
}

-(void) fillCellWithPhoto:(TWPhotoStruct *) photo {
    [self hideDeleteButton];
    [self loadPhoto:photo];
}

-(void)loadPhoto:(TWPhotoStruct *) photo {
    if ([photo isNeedPauseBeforeApearing]) {
        [photo setIsNeedPauseBeforeApearing:NO];
        self.imagePhoto.alpha = 0.0f;
        [self.imagePhoto sd_setImageWithURL:[NSURL URLWithString:[photo getMediumPhotoURL]]
                           placeholderImage:photo.placeholderImage];
        [self performSelector:@selector(setVisibleImage) withObject:nil afterDelay:timeAnimationImageToCellBeforeAppearing];
    } else {
        [self.imagePhoto sd_setImageWithURL:[NSURL URLWithString:[photo getMediumPhotoURL]]
                           placeholderImage:nil];
    }
}

-(void)setVisibleImage {
    self.imagePhoto.alpha = 1.0f;
}

- (IBAction)onTouchDeleteButton:(id)sender {
    UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"Подтверждение" message:@"Вы действительно хотите удалить фотографию" cancelButtonTitle:@"Отмена" otherButtonTitles:@"Да", nil];
    [alert showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL onCanceled) {
        if (onCanceled) return;
        if(selectedIndex == 1) {
            self.deleteBlock();
        }
    }];
}

-(void)showDeleteButton {
    [self.deleteButton setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        self.deleteButton.alpha = 1;
        self.constraintHeightDeleteButton.constant = deleteButtonSide;
        self.constraintWidthDeleteButton.constant = deleteButtonSide;
        [self.deleteButton layoutIfNeeded];
        [self.deleteButton setNeedsUpdateConstraints];
    }];
}

-(void)hideDeleteButton {
    [self.deleteButton setHidden:YES];
    self.deleteButton.alpha = 0;
    self.deleteButton.alpha = 1;
    self.constraintHeightDeleteButton.constant = 0;
    self.constraintWidthDeleteButton.constant = 0;
    [self layoutIfNeeded];
    [self.deleteButton setNeedsUpdateConstraints];
}


@end
