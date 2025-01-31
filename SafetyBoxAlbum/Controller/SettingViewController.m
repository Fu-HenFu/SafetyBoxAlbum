//
//  SettingViewController.m
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2025/1/9.
//
 
#import "SettingViewController.h"
#import "TSettingTableViewCell.h"
#import "TSwitchTableViewCell.h"
#import "Masonry.h"

@interface SettingViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *sectionData;
@property (nonatomic, strong) UIButton *buyBtn;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor: [UIColor whiteColor]];
    [self setupViews];
    
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
    
    
}

#pragma mark - UITableViewDataSource
 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}
 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sectionData[section] count];
}
 	
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        TSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell" forIndexPath:indexPath];
        
        [cell setTitle:self.sectionData[indexPath.section][indexPath.row]];
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3) {
            TSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
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
 
#pragma mark - UITableViewDelegate
 
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}
@end
