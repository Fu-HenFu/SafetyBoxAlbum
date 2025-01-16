//
//  TCreatePhotoView.m
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2025/1/7.
//

#import "TCreatePhotoView.h"
#import "Masonry.h"

@interface TCreatePhotoView()

@property (nonatomic, strong) UIButton *addButton;
@end

@implementation TCreatePhotoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    // 创建一个CAGradientLayer实例
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    
    // 设置渐变颜色，从半透明白色到完全不透明的白色
    gradientLayer.colors = @[(id)[UIColor colorWithWhite:1.0 alpha:0.6].CGColor,
                             (id)[UIColor whiteColor].CGColor];
    
    // 设置渐变方向，从顶部到底部
    gradientLayer.startPoint = CGPointMake(0.5, 0.0);
    gradientLayer.endPoint = CGPointMake(0.5, 1.0);
    
    // 将CAGradientLayer添加到自定义视图的层中
    [self.layer insertSublayer:gradientLayer atIndex:0];
    self.backgroundColor = [UIColor clearColor];
    CGSize targetSize = CGSizeMake(40, 40); // 例如，20x20 像素
    // 创建三个按钮
    UIImage *pictureImage = [UIImage imageNamed:@"newPicture"];
    pictureImage = [self image:pictureImage resizedToSize:targetSize];
    self.pictureButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    
    [self.pictureButton setTitle:@"照片" forState:UIControlStateNormal];
    [self.pictureButton setImage:pictureImage forState:UIControlStateNormal];
    // 调整图片和文字的位置（可选）
    self.pictureButton.imageEdgeInsets = UIEdgeInsetsMake(-30, 30, 0, 0); // 根据需要调整插图
    self.pictureButton.titleEdgeInsets = UIEdgeInsetsMake(30, -30, 0, 0);  // 根据需要调整插图
    self.pictureButton.hidden = YES; // 初始隐藏
    
    UIImage *takePictureImage = [UIImage imageNamed:@"newTakePicture"];
    takePictureImage = [self image:takePictureImage resizedToSize:targetSize];
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [self.cameraButton setTitle:@"拍摄" forState:UIControlStateNormal];
    [self.cameraButton setImage:takePictureImage forState:UIControlStateNormal];
    // 调整图片和文字的位置（可选）
    self.cameraButton.imageEdgeInsets = UIEdgeInsetsMake(-30, 30, 0, 0); // 根据需要调整插图
    self.cameraButton.titleEdgeInsets = UIEdgeInsetsMake(30, -30, 0, 0);  // 根据需要调整插图
    self.cameraButton.hidden = YES; // 初始隐藏
    
    // 将按钮添加到视图中
    [self addSubview:self.pictureButton];
    [self addSubview:self.cameraButton];
    
    CGFloat buttonHeight = 90.0f; // 设置按钮高度为30点
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat jj = (screenWidth - buttonHeight * 2 - 30 ) / 2;
    
    [self.pictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX).offset(-40);
        make.centerY.equalTo(@(self.bounds.size.height - 150 - 100));
        make.height.equalTo(@(buttonHeight));
        make.width.equalTo(@(buttonHeight));
    }];
    
    [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX).offset(40);
        make.centerY.equalTo(@(self.bounds.size.height - 150 - 100));
        make.height.equalTo(@(buttonHeight));
        make.width.equalTo(@(buttonHeight));
    }];
    
    UIImage *addImage = [UIImage imageNamed:@"CenterButtonIconPaw"];

    //    addImage = [self image:addImage resizedToSize:targetSize];
    self.addButton = [[UIButton alloc]init];
    [self.addButton setImage:addImage forState:UIControlStateNormal];

    // 调整图片和文字的位置（可选）
    self.addButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0); // 根据需要调整插图
    [self addSubview:self.addButton];
    CGFloat addButtonHeight = [addImage size].width; // 设置按钮高度为30点
    // 使用Masonry设置视图的约束
    
    @try {
        [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                // 对于iOS 11及以上版本，使用safeAreaLayoutGuide
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(0);
                
                make.centerX.equalTo(self.mas_centerX);
                
                make.height.equalTo(@(addButtonHeight));
                make.width.equalTo(@(addButtonHeight));
            }
        }];
    } @catch (NSException *exception) {
        // 捕获并处理异常
        NSLog(@"Caught an exception: %@", exception);

    }

    // 延迟调用动画以演示效果
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.pictureButton.hidden = NO; // 显示第一个按钮
            CGFloat ds = self.pictureButton.frame.origin.x;
            self.pictureButton.center = CGPointMake(self.pictureButton.frame.origin.x + self.pictureButton.frame.size.width / 2.0, self.bounds.size.height - 150 - 100);
    
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.cameraButton.hidden = NO; // 显示第二个按钮
                self.cameraButton.center = CGPointMake(self.cameraButton.frame.origin.x + self.pictureButton.frame.size.width / 2.0, self.bounds.size.height - 150 - 100);
            } completion:nil];
        }];
    });
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 在layoutSubviews中更新渐变层的大小，以适应视图的大小变化
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.frame = self.bounds;
        }
    }
}


- (UIImage *)image:(UIImage *)image resizedToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
