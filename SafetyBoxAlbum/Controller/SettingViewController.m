//
//  SettingViewController.m
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2025/1/9.
//
 
#import "SettingViewController.h"
#import "TSettingTableViewCell.h"
#import "TSwitchTableViewCell.h"
#import "TEmailSettingViewController.h"
#import "Masonry.h"
#import <THPinViewController.h>

@interface SettingViewController () <THPinViewControllerDelegate> {
    NSInteger _selectedRow;
    NSInteger _selectedSection;
    NSInteger _setPwdCount;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *sectionData;
@property (nonatomic, strong) UIButton *buyBtn;
@property (nonatomic, strong) NSString *firstPin;
@property (nonatomic, strong) THPinViewController *pinViewController;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor: [UIColor whiteColor]];
    [self setupViews];
    _setPwdCount = 0;
    
}

- (void)setupViews {
    UIView *memberView = [[UIView alloc]init];
    [memberView setBackgroundColor:[UIColor lightGrayColor]];
    self.buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buyBtn setTitle:@"点击我" forState:UIControlStateNormal];
    [self.buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [memberView addSubview:self.buyBtn];
    [self.view addSubview:memberView];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, screenWidth * 0.4, self.view.bounds.size.width, self.view.bounds.size.height - screenWidth * 0.4)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    // 在viewDidLoad中注册单元格
    [self.tableView registerClass:[TSettingTableViewCell class] forCellReuseIdentifier:@"NormalCell"];
    [self.tableView registerClass:[TSwitchTableViewCell class] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerClass:[TSettingTableViewCell class] forCellReuseIdentifier:@"SubNormalCell"];
    
    // 初始化数据
    self.sectionTitles = @[@"修改密码接受邮箱", @"安全", @"通用", @"关于"];
    self.sectionData = @[@[@"邮箱"], @[@"解锁密码", @"修改密码", @"Face ID", @"假密码", @"修改假密码", @"更改应用程序图标", @"入侵记录"], @[@"语言"], @[@"常见问题", @"分享", @"关于我们", @"版本号"]];
    
    [memberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(0);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.equalTo(@(screenWidth * 0.4));
        make.left.equalTo(self.view).offset(60);
        make.right.equalTo(self.view).offset(-60);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(memberView.mas_bottom).offset(10);
        make.centerX.equalTo(self.view.mas_centerX);
        make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        
    }];
//    _switchGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchGestureRecognizer:)];
    

    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sectionData[section] count];
}

# pragma UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectedRow = indexPath.row;
    _selectedSection = indexPath.section;
    
    if (indexPath.section == 0) {
        TEmailSettingViewController *controller = [[TEmailSettingViewController alloc]init];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
//                        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        } else if (indexPath.row == 1) {
            
        }
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        TSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
        
        [cell setTitle:self.sectionData[indexPath.section][indexPath.row]];
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3) {
            TSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
            if (indexPath.row == 0 || indexPath.row == 3) {
                cell.delegate = self;
            } else {
                cell.faceIdDelegate = self;
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//            [cell setUserInteractionEnabled:NO];    //  使得cell,以及子view都不可点击
            [cell.chosenSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            UITapGestureRecognizer *overlayGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(overlayGestureRecognizer)];
            
//            [cell.overlayView addGestureRecognizer:overlayGesture];
            
            [cell setTitle:self.sectionData[indexPath.section][indexPath.row]];
            return cell;
        } else if (indexPath.row == 6) {
            TSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
            
            [cell setTitle:self.sectionData[indexPath.section][indexPath.row]];
            [cell setStateLabel:NO];
            return cell;
            
        } else {
            
            TSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
            
            [cell setTitle:self.sectionData[indexPath.section][indexPath.row]];
            return cell;
        }
    } else if (indexPath.section == 2) {
        
        TSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
        
        [cell setTitle:self.sectionData[indexPath.section][indexPath.row]];
        return cell;
    } else {
        TSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
        
        [cell setTitle:self.sectionData[indexPath.section][indexPath.row]];
        return cell;
    }
    
    
}

#pragma User Method

/// 展示设置密码Controller
- (void)showPassWordViewController {
    self.pinViewController = [[THPinViewController alloc] initWithDelegate:self];
    
    self.pinViewController.promptTitle = @"输入密码";
    UIColor *darkBlueColor = [UIColor colorWithRed:0.012f green:0.071f blue:0.365f alpha:1.0f];
    self.pinViewController.promptColor = darkBlueColor;
    self.pinViewController.view.tintColor = darkBlueColor;
    
    // for a solid background color, use this:
    self.pinViewController.backgroundColor = [UIColor whiteColor];
    
    // for a translucent background, use this:
    self.view.tag = THPinViewControllerContentViewTag;
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.pinViewController.translucentBackground = NO;
    
    [self presentViewController:self.pinViewController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

#pragma THPinViewDelegate
- (NSUInteger)pinLengthForPinViewController:(nonnull THPinViewController *)pinViewController {
    return 4;
}

- (BOOL)pinViewController:(nonnull THPinViewController *)pinViewController isPinValid:(nonnull NSString *)pin {
    if (!self.firstPin) {
        self.firstPin = pin;
        // 关闭当前界面
                [self.pinViewController dismissViewControllerAnimated:YES completion:^{
                    // 弹出第二个密码输入界面
                    THPinViewController *secondPinViewController = [[THPinViewController alloc] initWithDelegate:self];
                    secondPinViewController.promptTitle = @"再次输入密码";
                    [self presentViewController:secondPinViewController animated:YES completion:nil];
                }];
        
        return NO; // 不关闭第一个界面
        
    } else {
        
        // 第二次输入密码
                if ([pin isEqualToString:self.firstPin]) {
                    // 密码匹配
                    [pinViewController dismissViewControllerAnimated:YES completion:^{
                        NSLog(@"密码设置成功！");
                        // 这里可以执行密码设置成功后的操作
                    }];
                    
                    [self changeSwitchValue];
                    return YES;
                } else {
                    // 密码不匹配
                    self.firstPin = nil;
                    [pinViewController dismissViewControllerAnimated:YES completion:^{
                        // 提示密码不匹配
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"密码不匹配，请重试" preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                        [self presentViewController:alert animated:YES completion:nil];
                    }];
                    return NO;
                }
        
        return YES;
    }
}

- (BOOL)userCanRetryInPinViewController:(nonnull THPinViewController *)pinViewController {
    return YES;
}


/// UISwitch 点击事件
/// - Parameter sender: 事件对象
- (void)switchValueChanged:(UISwitch *)sender {
    
    if (!sender.isOn) {
        NSLog(@"is On");
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:_selectedSection];
        TSwitchTableViewCell *cell = (TSwitchTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.overlayView setHidden:NO];
        return;
    }
    NSLog(@"yeah %@", @"hi");
}

- (void)overlayGestureRecognizer {
    [self showPassWordViewController];
}


/// 设置密码的uiswitch代理方法
/// - Parameter cell: 对应的cell对象
- (void)showPasswordSetting:(UITableView *)cell {
    _firstPin = nil;
    // 获取当前 cell 的 indexPath
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Custom view tapped in cell at row %ld", (long)indexPath.row);
    _selectedRow = indexPath.row;
    _selectedSection = indexPath.section;
    
    [self showPassWordViewController];
    
}

/// 设置FaceID的uiswitch代理方法
/// - Parameter cell: 对应的cell对象
- (void)showFaceIdSetting:(UITableView *)cell {
    _firstPin = nil;
    // 获取当前 cell 的 indexPath
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Custom view tapped in cell at row %ld", (long)indexPath.row);
    _selectedRow = indexPath.row;
    _selectedSection = indexPath.section;
    [self showPassWordViewController];
}

- (void)pinViewControllerDidDismissAfterPinEntryWasCancelled:(THPinViewController *)pinViewController {
    [pinViewController dismissViewControllerAnimated:YES completion:nil];

}

/// 修改switch的value
- (void)changeSwitchValue {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectedRow inSection:_selectedSection];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([[self.tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[TSwitchTableViewCell class]]) {
        TSwitchTableViewCell *cell = (TSwitchTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.chosenSwitch setOn:YES];
        [cell.overlayView setHidden:YES];
    }
}
@end
