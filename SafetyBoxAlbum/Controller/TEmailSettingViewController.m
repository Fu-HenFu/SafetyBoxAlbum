//
//  TEmailSettingViewController.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/2/12.
//

#import "TEmailSettingViewController.h"
#import <Masonry.h>

@interface TEmailSettingViewController ()

@end

@implementation TEmailSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViews];
}	

- (void)setupViews {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *iconImageView = [[UIImageView alloc]init];
    [iconImageView setImage:[UIImage imageNamed:@"email"]];
    [self.view addSubview:iconImageView];
    
    UILabel *tipsView = [[UILabel alloc]init];
    [tipsView setLineBreakMode:NSLineBreakByWordWrapping];
    [tipsView setText:@"如果你忘记了密码,我们将向这个邮箱发送找回密码邮件"];
    [self.view addSubview:tipsView];
    
    UITextField *emailTextField = [[UITextField alloc]init];
    [emailTextField setBorderStyle:UITextBorderStyleLine];
    [emailTextField setPlaceholder:@"电子邮箱"];
    [self.view addSubview:emailTextField];
    
    UIButton *comfirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CALayer *buttonLayer = comfirmButton.layer;
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:4];
    [comfirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [comfirmButton setBackgroundColor:[UIColor colorWithRed:28/255.0 green:142/255.0 blue:255/255.0 alpha:1]];
    [self.view addSubview:comfirmButton];
    
    [comfirmButton addTarget:self action:@selector(comfirmAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(60);
            make.centerX.equalTo(self.view.mas_centerX);
            make.width.equalTo(self.view.mas_width).multipliedBy(0.5);
            make.height.equalTo(self.view.mas_width).multipliedBy(0.5); 
    }];
    
    int viewHeight = self.view.frame.size.height;
    [tipsView setNumberOfLines:0];
    [tipsView setLineBreakMode:NSLineBreakByWordWrapping];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(iconImageView.mas_bottom).offset(self.view.bounds.size.height * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.6);
        
        
    }];
    
    [emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsView.mas_bottom).offset(self.view.bounds.size.height * 0.02);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.6);
    }];
    
    [comfirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(emailTextField.mas_bottom).offset(self.view.bounds.size.height * 0.05);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.6);
        make.height.equalTo(@44);
    }];
}

- (void)comfirmAction:(UIButton *)sender {
    
}

@end
