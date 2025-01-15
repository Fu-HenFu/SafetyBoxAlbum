//
//  TSettingTableViewCell.h
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2025/1/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSettingTableViewCell : UITableViewCell

- (void)setTitle:(NSString *)titleContent;
- (void)setNewLabel:(BOOL)flag;
- (void)setStateLabel:(BOOL)flag;


@end

NS_ASSUME_NONNULL_END
