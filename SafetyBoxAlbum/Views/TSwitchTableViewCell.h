//
//  TSwitchTableViewCell.h
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2025/1/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSwitchTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *chosenSwitch;

- (void)setTitle:(NSString *)titleContent;
- (void)setSwitch:(BOOL)switchState;
- (void)switchValueChanged:(UISwitch *)sender;
@end

NS_ASSUME_NONNULL_END
