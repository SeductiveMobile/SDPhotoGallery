//
//  ViewController.m
//  PhotoGallery
//
//  Created by Bohdan on 07.07.15.
//  Copyright (c) 2015 seductive. All rights reserved.
//

#import "ViewController.h"
#import "TWUploaderImage.h"
#import "CredentialStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "IDMPhotoBrowser.h"
#import "TWPhotoStruct.h"
#import "TWUploaderImage.h"
#import "UIGalleryToServer.h"
#import "SVProgressHUD.h"


typedef enum {
    kActionSheetTypeMethod,
    kActionSheetCellActions
} kActionSheetType;

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSIndexPath * selectedCellWithIndexPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onTouchAddPhoto:(id)sender {
    UIActionSheet * methodType = [[UIActionSheet alloc] init];
    methodType.tag = kActionSheetTypeMethod;
    methodType.title = @"Выбирете способ";
    [methodType addButtonWithTitle:@"Отмена"];
    [methodType addButtonWithTitle:@"Из галереи"];
    [methodType addButtonWithTitle:@"Сделать снимок"];
    methodType.cancelButtonIndex = 0;
    methodType.delegate = self;
    [methodType showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

-(void) loadPhotos {
    __weak typeof (self) weakSelf = self;
    [UIGalleryToServer loadPhotosWithParams:nil success:^(id responseObject) {
        weakSelf.dataSource = [NSMutableArray array];
        [self.dataSource addObject:responseObject];
        [weakSelf.collectionView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Не удалось загрузить" maskType:SVProgressHUDMaskTypeGradient];
    }];
}


-(void)addListenersToShowDeleteButton {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionsAfterLongPress:)];
    longPress.delegate = self;
    [self.collectionView addGestureRecognizer:longPress];
}

- (void)showActionsAfterLongPress:(UILongPressGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[gr locationInView:self.collectionView]];
        if (indexPath) {
            self.selectedCellWithIndexPath = indexPath;
            [self showCellActions];
        }
    }
}

-(void) showCellActions {
    UIActionSheet * photoActions = [[UIActionSheet alloc] init];
    photoActions.tag = kActionSheetCellActions;
    photoActions.title = @"Выбирете действие";
    [photoActions addButtonWithTitle:@"Отмена"];
    [photoActions addButtonWithTitle:@"Сделать фотографию главной"];
    [photoActions addButtonWithTitle:@"Удалить фотографию"];
    photoActions.cancelButtonIndex = 0;
    photoActions.delegate = self;
    [photoActions showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    if(actionSheet.tag == kActionSheetTypeMethod) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = YES;
        if (buttonIndex == 1) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else if (actionSheet.tag == kActionSheetCellActions) {
        if (buttonIndex == 1) {
            // TO DO Make Photo Main
        } else {
            [self deletePhotoAtIndexPath:self.selectedCellWithIndexPath];
        }
    }
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSIndexPath * indexPathForAppearing = [NSIndexPath indexPathForRow:0 inSection:0];
    [TWUploaderImage setSuccessBlock:^{
        
    }];
    [TWUploaderImage uploadImage:editedImage withParams:nil animationAfterLoadingToIndexPath:indexPathForAppearing forGalery:self];
}


#pragma mark -
#pragma mark Delete Photo

-(void)deletePhotoAtIndexPath:(NSIndexPath *)indexPath {
    TWPhotoStruct * photo = (self.dataSource[indexPath.section])[indexPath.row];
    NSDictionary * params = @{@"photo_id":photo.photoID}; // can be parameters as you wish
    __weak typeof(self) weakSelf = self;
    [UIGalleryToServer deletePhotoWithParams:params success:^(id responseObject) {
        [SVProgressHUD dismiss];
        [weakSelf removePhotoFromLocalStoreAndRefreshUIWithIndexPath:indexPath];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Не удалось удалить, попробуйте еще раз" maskType:SVProgressHUDMaskTypeGradient];
    }];
}

-(void)removePhotoFromLocalStoreAndRefreshUIWithIndexPath:(NSIndexPath *)indexPath {
    [(self.dataSource[indexPath.section]) removeObjectAtIndex:indexPath.row];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    [self showNoPhotoAlertIfNeeded];
}


@end
