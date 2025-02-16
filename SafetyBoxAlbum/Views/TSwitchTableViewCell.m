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
//        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
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
    [self.chosenSwitch setTranslatesAutoresizingMaskIntoConstraints:NO];
    UITapGestureRecognizer *switchGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchGestureRecognizer:)];
//    [self.chosenSwitch addGestureRecognizer:switchGesture];
    
    // 创建覆盖的UIView
    self.overlayView = [[UIView alloc] init];
    self.overlayView.backgroundColor = [UIColor clearColor]; // 确保是透明的
    
    UITapGestureRecognizer *overlayGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(overlayGestureRecognizer:)];
    [self.overlayView addGestureRecognizer:overlayGesture];
    
//    [self.overlayView setUserInteractionEnabled:YES];
//    self.overlayView.userInteractionEnabled = NO; // 确保不拦截用户交互
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.chosenSwitch];
    [self.contentView addSubview:self.overlayView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(40);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.chosenSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-50);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.overlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.chosenSwitch); // 边缘与UISwitch对齐
    }];
    
    
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

- (void)switchGestureRecognizer:(UITapGestureRecognizer *)tap {
    [self.overlayView setHidden:NO];
    // 切换 UISwitch 的状态
    self.chosenSwitch.on = !self.chosenSwitch.on;
    // 触发 Cell 的点击事件
//    UITableView *tableView = (UITableView *)self.superview;
//    NSIndexPath *indexPath = [tableView indexPathForCell:self];
//    if (indexPath) {
//        [tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
//    }
}

- (void)overlayGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(showPasswordSetting:)]) {
        [self.delegate showPasswordSetting:self];
        return;
    }
    if ([self.faceIdDelegate respondsToSelector:@selector(showFaceIdSetting:)]) {
        [self.faceIdDelegate showFaceIdSetting:self];
        return;
    }
    NSLog(@"yeah %@", @"hi");
}


@end
	
