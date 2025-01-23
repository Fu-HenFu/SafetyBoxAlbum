//
//  TPictureDetailViewController.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/16.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>
#import <LFPhotoEditingController.h>
#import <CLPhotoCrop.h>

#import <SCLAlertView.h>
#import "GlobalDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface TPictureDetailViewController : UIViewController <UIScrollViewDelegate, CLPhotoShopViewControllerDelegate>

/** 需要保存到编辑数据 */
@property (nonatomic, strong) LFPhotoEdit *photoEdit;
//@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image; // 从前一个视图控制器传递过来的图片

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath assetsFetchResults:(PHFetchResult *)assetsFetchResults imageManager:(PHCachingImageManager *)imageManager andAlbumId:(NSInteger)albumId andAlbumName:(NSString *)albumName;
@end

NS_ASSUME_NONNULL_END
