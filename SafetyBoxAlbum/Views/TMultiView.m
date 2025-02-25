//
//  TMultiView.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/2/17.
//

#import "TMultiView.h"

#import <Masonry.h>
#define ImageWidth 30

@interface TMultiView()

@end

@implementation TMultiView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    // 获取父视图的宽度
    CGFloat parentWidth = self.bounds.size.width;
        
    // 计算按钮宽度
    CGFloat buttonWidth = parentWidth / 7.0;
    
    self.moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moveButton setTitle:@"移至" forState:UIControlStateNormal];
    [self.moveButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIImage *moveImg = [UIImage imageNamed:@"movePicture"];
    moveImg = [self resizeImage:moveImg];

    [self.moveButton setImage:moveImg forState:UIControlStateNormal];
    self.moveButton.imageEdgeInsets = UIEdgeInsetsMake(-(buttonWidth/2), ((buttonWidth - ImageWidth)/2), 0, 0); // 根据需要调整插图
    self.moveButton.titleEdgeInsets = UIEdgeInsetsMake(0, -moveImg.size.width, -moveImg.size.height*1.2, 0);  //
    
//    self.moveButton.titleEdgeInsets = UIEdgeInsetsMake(0, -moveImg.size.width, -moveImg.size.height - 20, 0)根据需要调整插图
    [self addSubview:self.moveButton];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [self.shareButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIImage *shareImg = [UIImage imageNamed:@"sharePicture"];
    shareImg = [self resizeImage:shareImg];
    [self.shareButton setImage:shareImg forState:UIControlStateNormal];
    self.shareButton.imageEdgeInsets = UIEdgeInsetsMake(-(buttonWidth/2), ((buttonWidth - ImageWidth)/2), 0, 0); // 根据需要调整插图
    self.shareButton.titleEdgeInsets = UIEdgeInsetsMake(0, -shareImg.size.width, -shareImg.size.height*1.2, 0);  //
    
    [self addSubview:self.shareButton];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIImage *deleteImg = [UIImage imageNamed:@"garbagePicture"];
    deleteImg = [self resizeImage:deleteImg];
    [self.deleteButton setImage:deleteImg forState:UIControlStateNormal];
    self.deleteButton.imageEdgeInsets = UIEdgeInsetsMake(-(buttonWidth/2), ((buttonWidth - ImageWidth)/2), 0, 0); // 根据需要调整插图
    self.deleteButton.titleEdgeInsets = UIEdgeInsetsMake(0, -deleteImg.size.width, -deleteImg.size.height*1.2, 0);  //
    [self addSubview:self.deleteButton];
    
    // 创建一个水平排列的数组
        NSArray *views = @[self.moveButton, self.shareButton, self.deleteButton];
     
        // 使用 Masonry 分布视图
        CGFloat padding = buttonWidth; // 每侧的总间距

    [views mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:padding leadSpacing:padding tailSpacing:padding];

     
    // 设置每个子视图的宽度相等
    [views mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.height.equalTo(@80); // 设置每个视图的高度
    }];
    
    
}

/// 制作一个新尺寸的UIImage
/// - Parameter originImage: 原始image
- (UIImage *)resizeImage:(UIImage *)originImage {
    UIImage *resizedImage;
    if (@available(iOS 15.0, *)) {
        resizedImage = [originImage imageByPreparingThumbnailOfSize:CGSizeMake(ImageWidth, ImageWidth)];
    } else {
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(ImageWidth, ImageWidth)];
           resizedImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
               [originImage drawInRect:CGRectMake(0, 0, ImageWidth, ImageWidth)];
           }];

        // Fallback on earlier versions
    }
    return resizedImage;
}

@end
