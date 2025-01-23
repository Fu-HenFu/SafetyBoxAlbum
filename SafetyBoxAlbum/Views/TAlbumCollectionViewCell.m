//
//  TAlbumCollectionViewCell.m
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2024/12/22.
//

#import "TAlbumCollectionViewCell.h"

@interface TAlbumCollectionViewCell()
@property (assign, nonatomic) CGFloat screenWidth;
@property (assign, nonatomic) CGFloat screenHeight;

@end

@implementation TAlbumCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];

    }
    return self;
}

- (void)setupViews {
//    [self setBackgroundColor:[UIColor yellowColor]];
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // 初始化子视图
    CGSize targetSize = CGSizeMake(self.screenWidth * 0.4, self.screenWidth * 0.4); // 例如，20x20 像素
    UIImage *iconImage = [self image:[UIImage imageNamed:@"album_select"] resizedToSize:targetSize];
    self.iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    self.iconImageView.backgroundColor = [UIColor lightGrayColor];
    self.iconImageView.clipsToBounds = YES;
    
    // 设置圆角
//    self.iconImageView.layer.cornerRadius = 12; // 圆角半径为宽度或高度的一半即为圆形
    self.iconImageView.layer.borderColor = [UIColor whiteColor].CGColor; // 可选：设置边框颜色


    self.iconImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapped:)];
    [self.iconImageView addGestureRecognizer:tapGestureRecognize];
    
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.iconImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.titleLabel.userInteractionEnabled = YES;
    self.titleLabel.text = @"收藏夹";
    self.titleLabel.font = [UIFont systemFontOfSize:16];
//    self.titleLabel.backgroundColor = [UIColor redColor];
    UITapGestureRecognizer *titleGestureRecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapped:)];
    [self.titleLabel addGestureRecognizer:titleGestureRecognize];
    [self.contentView addSubview:self.titleLabel];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.text = @"0个文件";
    self.detailLabel.font = [UIFont systemFontOfSize:14];
    self.detailLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.detailLabel];
    self.detailLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *detailGestureRecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapped:)];
    [self.detailLabel addGestureRecognizer:detailGestureRecognize];
    
    self.moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreButton setImage:[UIImage imageNamed:@"moreDots"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.moreButton];
    
    CALayer *contentLayer = self.contentView.layer;
    contentLayer.borderColor = UIColor.lightGrayColor.CGColor;
    contentLayer.borderWidth = 1;
    contentLayer.cornerRadius = 6;
    contentLayer.masksToBounds = YES;
    
    // 使用Masonry设置约束
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top);
        make.width.height.equalTo(@(self.screenWidth * 0.4)); // 假设图标的宽度和高度都是80
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_left).offset(10);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(6);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_left);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.contentView.mas_right).offset(10);
        make.right.equalTo(self.iconImageView.mas_right).offset(-10);
        make.width.height.equalTo(@30); // 假设图标的宽度和高度都是80
        make.centerY.equalTo(self.titleLabel.mas_centerY).offset(10);
    }];
    
    
}

- (UIImage *)image:(UIImage *)image resizedToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (void)imageViewTapped:(UITapGestureRecognizer *)gestureRecognizer {
    
}

- (void)labelTapped:(nonnull UITapGestureRecognizer *)gestureRecognizer {
    // 调用代理方法
    if ([self.delegate respondsToSelector:@selector(showAlbumClick:didTapButton:)]) {
        UIView *triggeringView = gestureRecognizer.view; // 这就是触发手势的视图
        if ([triggeringView isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)triggeringView;
        }
        NSString *albumName = self.titleLabel.text;
        [self.delegate showAlbumClick:self didTapButton:albumName];
    }
}

- (void)setAlbumCell:(nonnull NSString *)albumName withCoverImage:(nonnull NSString *)imagePath {
    
}


- (void)moreAction:(UIButton *)sender {
    // 调用代理方法
    if ([self.delegate respondsToSelector:@selector(showAlbumToosClick:)]) {
        // 你可以在这里对triggeringView进行进一步的操作
        [self.delegate showAlbumToosClick:self];
    }
    
}


- (void)prepareForReuse {
    [super prepareForReuse];
    // 重置自定义值，确保重用单元格时不会受到影响
    self.albumName = nil;
}

@end
