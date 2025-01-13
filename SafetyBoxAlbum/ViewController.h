//
//  ViewController.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//

#import <UIKit/UIKit.h>

#import "TAlbumCollectionViewCell.h"
#import "UIToolbar+EEToolbarCenterButton.h"
#import "TStorage.h"
#import "TAlbumObject.h"
#import "AlbumSettingViewController.h"
#import "AlbumHeaderView.h"
#import "TCreateAlbumPhotoView.h"
#import "TStorage.h"
#import "SettingViewController.h"
#import "TAlbumCollectionViewCell.h"

@interface ViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIToolbar *toolBar2;
@property (strong, nonatomic) UIBarButtonItem *barButtonItem;

@property (nonatomic, strong) NSIndexPath *fixedCellIndexPath;  //  固定cell的indexPath
@property (nonatomic, strong) TStorage *storage;

@property (nonatomic, strong) NSMutableArray  *dataArray; // 用于存储数据的数组
@property (strong, nonatomic) TCreateAlbumPhotoView *createItemView;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

- (void)setupViews;
- (UIImage *)image:(UIImage *)image resizedToSize:(CGSize)newSize;
- (void)settingsTapped:(UIButton *)sender;

@end

