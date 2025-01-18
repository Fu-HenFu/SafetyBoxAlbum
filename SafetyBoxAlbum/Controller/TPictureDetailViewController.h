//
//  TPictureDetailViewController.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPictureDetailViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image; // 从前一个视图控制器传递过来的图片

@end

NS_ASSUME_NONNULL_END
