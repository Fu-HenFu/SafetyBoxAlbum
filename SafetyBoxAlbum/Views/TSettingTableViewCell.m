//
//  TSettingTableViewCell.m
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2025/1/9.
//

#import "TSettingTableViewCell.h"
#import "Masonry.h"

@interface TSettingTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *theNewView;
@property (nonatomic, strong) UILabel *stateLabel;

@end

@implementation TSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 初始化代码
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator; // 设置右侧箭头
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.titleLabel = [[UILabel alloc]init];
    self.theNewView = [[UIImageView alloc]init];
    self.theNewView.image = [UIImage imageNamed:@"newTips"];
    [self.theNewView setHidden:YES];
    
    self.stateLabel = [[UILabel alloc]init];
    [self.stateLabel setHidden:YES];
    [self.stateLabel setText:@"关闭"];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.theNewView];
    [self addSubview:self.stateLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(40);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(self.mas_width).multipliedBy(0.4);
        make.height.equalTo(@40);
    }];
    
    [self.theNewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-40); // 留出空间给箭头
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.equalTo(@40);
        
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-40); // 留出空间给箭头
        make.centerY.equalTo(self.contentView.mas_centerY);
        
        make.width.equalTo(@80);
    }];
}

- (void)setTitle:(NSString *)titleContent {
    [self.titleLabel setText:titleContent];
}

- (void)setNewLabel:(BOOL)flag {
    [self.theNewView setHidden:flag];
}

- (void)setStateLabel:(BOOL)flag {
    [self.stateLabel setHidden:flag];
}


@end
