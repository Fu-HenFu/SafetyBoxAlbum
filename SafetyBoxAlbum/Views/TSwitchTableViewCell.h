//
//  TSwitchTableViewCell.h
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2025/1/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TSwitchCellDelegate <NSObject>

- (void)showPasswordSetting:(UITableView *)cell;

@end

@protocol TSwitchCellFaceIdDelegate <NSObject>

- (void)showFaceIdSetting:(UITableView *)cell;

@end

@interface TSwitchTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UISwitch *chosenSwitch;
@property (nonatomic, weak) id<TSwitchCellDelegate> delegate;
@property (nonatomic, weak) id<TSwitchCellFaceIdDelegate> faceIdDelegate;

- (void)setTitle:(NSString *)titleContent;
- (void)setSwitch:(BOOL)switchState;
- (void)switchValueChanged:(UISwitch *)sender;
	
@end

NS_ASSUME_NONNULL_END
