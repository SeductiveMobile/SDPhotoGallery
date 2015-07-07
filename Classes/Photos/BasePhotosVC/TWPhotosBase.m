//
//  TWPhotosBase.m
//  TezWay
//
//  Created by Bohdan on 22.06.15.
//  Copyright (c) 2015 seductive.com.ua. All rights reserved.
//

#import "TWPhotosBase.h"
#import "TXPhotoCVC.h"
#import "IDMPhoto.h"
#import "IDMPhotoBrowser.h"


@interface TWPhotosBase ()

@end

@implementation TWPhotosBase

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray arrayWithCapacity:1];
    [self.dataSource addObject:[NSMutableArray array]];
    [self.collectionView registerClass:[TXPhotoCVC class] forCellWithReuseIdentifier:photoCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([TXPhotoCVC class]) bundle:[NSBundle bundleForClass:[TXPhotoCVC class]]] forCellWithReuseIdentifier:photoCellIdentifier];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Delete Item

-(void)removePhotoFromLocalStoreAndRefreshUIWithIndexPath:(NSIndexPath *)indexPath {
    [(self.dataSource[indexPath.section]) removeObjectAtIndex:indexPath.row];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self showNoPhotoAlertIfNeeded];
}

-(void)showNoPhotoAlertIfNeeded {
    
}


#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataSource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TXPhotoCVC *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:photoCellIdentifier forIndexPath:indexPath];
    TWPhotoStruct * photo = (self.dataSource[indexPath.section])[indexPath.row];
    [photoCell fillCellWithPhoto:photo];
    return photoCell;
}



#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self showPhotoWithIndexPath:indexPath];
}


#pragma mark -
#pragma mark Photo Browser

-(void)showPhotoWithIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray * photosURLs = [NSMutableArray array];
    for (NSMutableArray * images in self.dataSource) {
        [photosURLs addObjectsFromArray:[self getBrouseURLsForPhotos:images]];
    }
    
    NSArray *photos = [IDMPhoto photosWithURLs:[NSArray arrayWithArray:photosURLs]];
    TXPhotoCVC * cell = (TXPhotoCVC *)[self.collectionView cellForItemAtIndexPath:indexPath];
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:cell.imagePhoto];
    browser.displayActionButton = NO;
    browser.displayArrowButton = NO;
    browser.displayCounterLabel = YES;
    browser.forceHideStatusBar = YES;
    NSInteger initialIndex = 0;
    for (int i = 0; i < indexPath.section; i++) {
        initialIndex += [self.dataSource[i] count];
    }
    initialIndex += indexPath.row;
    
    [browser setInitialPageIndex:initialIndex];
    [self presentViewController:browser animated:YES completion:nil];
}

-(NSArray *)getBrouseURLsForPhotos:(NSMutableArray *)arrayM {
    NSMutableArray * res = [NSMutableArray arrayWithCapacity:[arrayM count]];
    for (TWPhotoStruct * photo in arrayM) {
        [res addObject:[photo getBrowserURL]];
    }
    return [NSArray arrayWithArray:res];
}




@end
