//
//  TGarbageMultiSelecteView.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/2/24.
//

#import "TGarbageMultiSelecteView.h"

#import <Masonry.h>

#define ImageWidth 30

@interface TGarbageMultiSelecteView()

@end

@implementation TGarbageMultiSelecteView

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
    
    self.restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.restoreButton setTitle:@"恢复" forState:UIControlStateNormal];
    [self.restoreButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIImage *restoreImg = [UIImage imageNamed:@"recoverPicture"];
    restoreImg = [self resizeImage:restoreImg];
    
    [self.restoreButton setImage:restoreImg forState:UIControlStateNormal];
    
//    self.moveButton.titleEdgeInsets = UIEdgeInsetsMake(0, -moveImg.size.width, -moveImg.size.height - 20, 0)根据需要调整插图
    [self addSubview:self.restoreButton];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIImage *deleteImg = [UIImage imageNamed:@"garbagePicture"];
    deleteImg = [self resizeImage:deleteImg];
    [self.deleteButton setImage:deleteImg forState:UIControlStateNormal];
    
    [self addSubview:self.deleteButton];
    
    // 创建一个水平排列的数组	
    NSArray *views = @[self.restoreButton, self.deleteButton];
     
        // 使用 Masonry 分布视
    CGFloat padding = buttonWidth; // 每侧的总间距

    [views mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:padding leadSpacing:padding tailSpacing:padding];

     
    // 设置每个子视图的宽度相等
    [views mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.height.equalTo(@80); // 设置每个视图的高度
    }];
    float cButtonWidth = (self.frame.size.width - padding * 3) / 2.0;
    
    // 获取图像和标题的尺寸
    CGSize imageSize = self.deleteButton.imageView.frame.size;
    CGSize titleSize = self.deleteButton.titleLabel.frame.size;
    // 计算图像的水平偏移量
        CGFloat imageOffsetX = (titleSize.width + imageSize.width) / 2 - imageSize.width / 2;
    
    CGFloat textOffsetX = (titleSize.width + imageSize.width) / 2 - titleSize.width / 2;
    
    self.deleteButton.imageEdgeInsets = UIEdgeInsetsMake(-(buttonWidth/2), imageOffsetX, 0, imageOffsetX*-1); // 根据需要调整插图
    self.deleteButton.titleEdgeInsets = UIEdgeInsetsMake(0, -textOffsetX, -deleteImg.size.height * 1.2, textOffsetX);  //
    
    // 获取图像和标题的尺寸
    CGSize rimageSize = self.restoreButton.imageView.frame.size;
    CGSize rtitleSize = self.restoreButton.titleLabel.frame.size;
    // 计算图像的水平偏移量
    CGFloat rimageOffsetX = (rtitleSize.width + rimageSize.width) / 2 - rimageSize.width / 2;
    CGFloat rtextOffsetX = (rtitleSize.width + rimageSize.width) / 2 - rtitleSize.width / 2;
    
    self.restoreButton.imageEdgeInsets = UIEdgeInsetsMake(-(buttonWidth/2), rimageOffsetX, 0, rimageOffsetX*-1); // 根据需要调整插图
    self.restoreButton.titleEdgeInsets = UIEdgeInsetsMake(0, rtextOffsetX*-1, -restoreImg.size.height*1.2, rtextOffsetX);  //
    
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
