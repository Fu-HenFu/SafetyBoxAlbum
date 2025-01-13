//
//  TSwitchTableViewCell.m
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2025/1/10.
//

#import "TSwitchTableViewCell.h"
#import "Masonry.h"

@implementation TSwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupViews {
    self.chosenSwitch = [[UISwitch alloc]init];
    [self addSubview:self.chosenSwitch];
    [self.chosenSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-50);
        make.centerY.equalTo(self.mas_centerY);
    }];
}

@end
