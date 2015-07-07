//
//  TXPhotoCVC.h
//  Tezway
//
//  Created by Bohdan on 12.06.15.
//  Copyright (c) 2015 seductive.com.ua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWPhotoStruct.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TXPhotoCVC : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imagePhoto;

-(void) fillCellWithPhoto:(TWPhotoStruct *) photo;
-(void) fillCellWithPhoto:(TWPhotoStruct *) photo deleteAction:(void (^) ())deleteBlock;
-(void) showDeleteButton;
-(void) hideDeleteButton;

@end
