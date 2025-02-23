//
//  TSelectAlbumViewController.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/2/18.
//

#import "TSelectAlbumViewController.h"
#import "TStorage.h"
#import "GlobalDefine.h"
#import <Masonry.h>
#import <SCLAlertView.h>


@interface TSelectAlbumViewController () <UITableViewDataSource, UITableViewDelegate>{
    
    NSString *_path;
    NSInteger _albumId;
    NSString *_albumName;
    int _photoCount;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TStorage *storage;
@property (nonatomic, strong) NSArray *albumArray;
@property (nonatomic, strong) UIButton *confirmButton;
@end

@implementation TSelectAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    [self setupView];
}

- (void)setupView {
    
    
    self.storage = [TStorage shareStorage];
    self.albumArray = [self.storage queryAlbum:ValuableState];
    
    UIView *titleView = [[UIView alloc]init];
    [titleView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *descriptionLabel = [[UILabel alloc]init];
    [descriptionLabel setText:@"选择移至的相册"];
    [descriptionLabel setTextColor: [UIColor blackColor]];
    [descriptionLabel setFont:[UIFont systemFontOfSize:26]];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.confirmButton setEnabled:NO];
    [self.confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [titleView addSubview:descriptionLabel];
    [titleView addSubview:self.confirmButton];
    
    [self.view addSubview:titleView];
    
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain ];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"albumCell"];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    
    [self.view addSubview:self.tableView];
    
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.width.equalTo(self.view.mas_width);
            make.height.equalTo(self.view.mas_width).multipliedBy(0.2);
    }];
    
    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(titleView.mas_centerX);
        make.centerY.equalTo(titleView.mas_centerY);
            make.width.equalTo(titleView.mas_width).multipliedBy(0.5);
            make.height.equalTo(titleView.mas_height).multipliedBy(0.8);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(titleView.mas_centerY);
            make.right.equalTo(titleView.mas_right).offset(-10);
        make.width.equalTo(titleView.mas_width).multipliedBy(0.1);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(titleView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TAlbumObject *obj = self.albumArray[indexPath.row];
    _albumId = obj.id; 
    _albumName = obj.name;
    _photoCount = self.selectedCount + obj.photoCount;
    [self.confirmButton setEnabled:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"albumCell"];

    }
    
    TAlbumObject *obj = self.albumArray[indexPath.row];
    [cell.textLabel setText:obj.name];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%d", obj.photoCount]];
    
    NSString *imagePath = [_path stringByAppendingPathComponent:[obj lastestImagePath]];

    [cell.imageView setImage:[UIImage imageNamed:imagePath]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}	

- (void)confirmAction:(UIButton *)comfirnButton {
//    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//    alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [NSBundle mainBundle].resourcePath]];
//    
//    [alert showInfo:self title:title subTitle:subTitle closeButtonTitle:closeTitle duration:0.0f];
    
    
    if ([self.delegate respondsToSelector:@selector(selectedAlbum:andAlbumName:andAlbumPhotoCount:)]) {
        [self.delegate selectedAlbum:_albumId andAlbumName:_albumName andAlbumPhotoCount:_photoCount];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

