//
//  TWPhotoCRV.m
//  Tezway
//
//  Created by Bohdan on 15.06.15.
//  Copyright (c) 2015 seductive.com.ua. All rights reserved.
//

#import "TWPhotoCRV.h"

@interface TWPhotoCRV()

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;


@end


@implementation TWPhotoCRV

- (void)awakeFromNib {
    // Initialization code
}

-(void)setTitle:(NSString *)title {
    self.labelTitle.text = title;
}

@end
