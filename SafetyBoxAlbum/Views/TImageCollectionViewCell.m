//
//  TImageCollectionViewCell.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/14.
//

#import "TImageCollectionViewCell.h"

@implementation TImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化并配置 UIImageView
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES; // 确保图片裁剪到边界
        [self.contentView addSubview:self.imageView];
    }
    return self;
}
 
- (void)layoutSubviews {
    [super layoutSubviews];
    // 确保 imageView 填充整个单元格
    self.imageView.frame = self.contentView.bounds;
}

@end
