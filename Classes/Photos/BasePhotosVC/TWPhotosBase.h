//
//  TWPhotosBase.h
//  TezWay
//
//  Created by Bohdan on 22.06.15.
//  Copyright (c) 2015 seductive.com.ua. All rights reserved.
//


static NSString * photoCellIdentifier = @"TXPhotoCVC";

@interface TWPhotosBase : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//dataSource:[userPhotos[],carPhotos[]...]
@property (strong, nonatomic) NSMutableArray * dataSource;

-(void)removePhotoFromLocalStoreAndRefreshUIWithIndexPath:(NSIndexPath *)indexPath;
-(void)showNoPhotoAlertIfNeeded;

@end
