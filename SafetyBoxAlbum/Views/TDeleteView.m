//
//  TDeleteView.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/14.
//

#import "TDeleteView.h"
#import "Masonry.h"

@implementation TDeleteView



- (instancetype)initWithImage:(UIImage *)image message:(NSString *)message {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3]; // 半透明背景
 
        // 创建内容视图
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.cornerRadius = 8.0;
        contentView.layer.masksToBounds = YES;
        [self addSubview:contentView];
 
        // 添加图片
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [contentView addSubview:imageView];
 
        // 添加标签
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        messageLabel.text = message;
        messageLabel.textAlignment = NSTextAlignmentCenter;
//        messageLabel.numberOfLines = 0;
        messageLabel.text = @"允许\"秘密相册\"删除这4张照片";
        [contentView addSubview:messageLabel];
        
        self.noExcuteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.noExcuteBtn setTitle:@"不删除" forState:UIControlStateNormal];
        [self.noExcuteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [contentView addSubview:self.noExcuteBtn];
        
        self.excuteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.excuteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.excuteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [contentView addSubview:self.excuteBtn];
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(contentView.mas_top);
                    make.left.equalTo(contentView.mas_left);
                    make.width.equalTo(@(screenWidth - 60 * 2));
                    make.height.equalTo(@100);
        }];
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.mas_centerX);
                    make.centerY.equalTo(self.mas_centerY);
                    make.width.equalTo(@(screenWidth - 60 * 2));
                    make.height.equalTo(@(screenWidth - 0));
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.mas_centerX);
                    make.centerY.equalTo(self.mas_centerY);
                    make.width.equalTo(contentView.mas_width);
                    make.height.equalTo(contentView.mas_width);
        }];
        
        [self.noExcuteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(imageView.mas_bottom);
                    make.left.equalTo(contentView.mas_left);
                    make.bottom.equalTo(contentView.mas_bottom);
            make.width.equalTo(contentView.mas_width).multipliedBy(0.5);
        }];
        
        
        [self.excuteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(imageView.mas_bottom);
                    make.right.equalTo(contentView.mas_right);
                    make.bottom.equalTo(contentView.mas_bottom);
            make.width.equalTo(contentView.mas_width).multipliedBy(0.5);
        }];
    }
    return self;
}
 
- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }];
}
 
- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
 

@end
