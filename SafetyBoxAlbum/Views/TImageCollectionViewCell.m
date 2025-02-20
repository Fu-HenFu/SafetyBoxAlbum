//
//  TImageCollectionViewCell.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/14.
//

#import "TImageCollectionViewCell.h"

@interface TImageCollectionViewCell () {
    BOOL _isMultiSelected;
}
@property (nonatomic, strong) UIImageView *selectionCircle;

@property (nonatomic, strong) UIView *overlayView;
@end

@implementation TImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        
        
    }
    return self;
}

- (void)setupViews {
    
    // 初始化并配置 UIImageView
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES; // 确保图片裁剪到边界
    [self.contentView addSubview:self.imageView];
//    photo_def_photoPickerVc
    // 创建选择状态的小圆圈
    self.selectionCircle = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 25 - 5, 5, 25, 25)];
    
    self.selectionCircle.layer.cornerRadius = 10;
    self.selectionCircle.backgroundColor = [UIColor clearColor];
//    self.selectionCircle.layer.borderColor = [UIColor grayColor].CGColor;
//    self.selectionCircle.layer.borderWidth = 1.0;
    [self.selectionCircle setImage:[UIImage imageNamed:@"photo_def_photoPickerVc"]];
    [self.selectionCircle setHidden:YES];
    
    self.overlayView = [[UIView alloc]initWithFrame:self.bounds];
    [self.overlayView setBackgroundColor:[UIColor colorWithWhite:211/255.0 alpha:0.4]];
    
    [self.contentView addSubview:self.selectionCircle];
    [self.contentView addSubview:self.overlayView];
    [self.overlayView setHidden:YES];
}
 
- (void)layoutSubviews {
    [super layoutSubviews];
    // 确保 imageView 填充整个单元格
    self.imageView.frame = self.contentView.bounds;
}

- (void)selectedImage:(BOOL)isSelected {
    if (isSelected) {
        
        [self.selectionCircle setImage:[UIImage imageNamed:@"photo_sel_photoPickerVc"]];
        [self.overlayView setHidden:NO];
        
//        [self.contentView insertSubview:self.overlayView belowSubview:self.selectionCircle];
//        [self.overlayView setUserInteractionEnabled:NO];
        [self animateImage];
        return;
    }
    [self.selectionCircle setImage:[UIImage imageNamed:@"photo_def_photoPickerVc"]];
    [self.overlayView setHidden:YES];
    
}

- (void)animateImage {
    // 设置动画参数	
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // 放大图片
                         self.selectionCircle.transform = CGAffineTransformMakeScale(1.2, 1.2);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             // 在放大动画完成后，缩小回原来的大小
                             [UIView animateWithDuration:0.5
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  self.selectionCircle.transform = CGAffineTransformIdentity;
                                              }
                                              completion:nil];
                         }
                     }];
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
}


- (void)setMultiSelected:(BOOL)isMultiSelected {
    _isMultiSelected = isMultiSelected;
    [self.selectionCircle setImage:[UIImage imageNamed:@"photo_def_photoPickerVc"]];
    [self.selectionCircle setHidden:!_isMultiSelected];
    [self.overlayView setHidden:YES];
}

@end
				
	
