//
//  TDeleteView.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDeleteView : UIView

@property (nonatomic, strong) UIButton *excuteBtn;
@property (nonatomic, strong) UIButton *noExcuteBtn;

- (instancetype)initWithImage:(UIImage *)image message:(NSString *)message;
- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
