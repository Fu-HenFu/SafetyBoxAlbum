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
    self.titleLabel = [[UILabel alloc]init];
    
    self.chosenSwitch = [[UISwitch alloc]init];
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.chosenSwitch];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(40);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.chosenSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-50);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.chosenSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)setTitle:(NSString *)titleContent {
    [self.titleLabel setText:titleContent];
}

- (void)setSwitch:(BOOL)switchState {
    [self.chosenSwitch setOn:switchState];
}

- (void)switchValueChanged:(UISwitch *)sender {
    NSLog(@"yeah %@", @"hi");
}

@end
	
