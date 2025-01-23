//
//  ViewController.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//Ô

#import "ViewController.h"
#import <Foundation/Foundation.h>



static NSString* const kCellConstant = @"CollectiveItem";

@interface ViewController ()

@end

@implementation ViewController

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize; // 允许自动估算大小
    
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 30;
    
    
    self.storage = [TStorage shareStorage];

    self.dataArray = [NSMutableArray arrayWithArray:[self.storage queryAlbum:1]];
    if (self = [super initWithCollectionViewLayout:layout]) {
        
    }
    // 调用父类的初始化方法
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    UIColor *dynamicColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
        if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            // 黑暗模式下的颜色
            self.view.backgroundColor = dynamicColor;
            return [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
        } else {
            // 明亮模式下的颜色
            self.view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
            return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        }
    }];
    // 创建标题标签并包装到 UIView 中
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)]; // 设置标签大小和位置
    titleLabel.text = @"相簿";
    titleLabel.font = [UIFont systemFontOfSize:36.0];
    titleLabel.textColor = [UIColor blackColor]; // 白色文字
    titleLabel.textAlignment = NSTextAlignmentRight; // 居中对齐
    
    UIView *titleView = [[UIView alloc] initWithFrame:titleLabel.frame];
    [titleView addSubview:titleLabel];
    
    // 将标题视图包装到 UIBarButtonItem 中
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleView];
//    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    self.navigationItem.titleView = titleView;
    
    // 创建“免费试用”按钮
    UIButton *freeTrialButton = [UIButton buttonWithType:UIButtonTypeSystem];
    freeTrialButton.frame = CGRectMake(0, 0, 80, 40); // 设置按钮大小
    [freeTrialButton setTitle:@"免费试用" forState:UIControlStateNormal];
    freeTrialButton.backgroundColor = [UIColor yellowColor]; // 黄色背景
    freeTrialButton.layer.cornerRadius = 20; // 圆形按钮
    freeTrialButton.clipsToBounds = YES;
    [freeTrialButton addTarget:self action:@selector(freeTrialTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // 将按钮包装到 UIBarButtonItem 中
    UIBarButtonItem *buyButtonItem = [[UIBarButtonItem alloc] initWithCustomView:freeTrialButton];
    
    UIImage *settingsImage = [UIImage imageNamed:@"setting"];
    // 目标尺寸（根据需要调整）
    CGSize targetSize = CGSizeMake(30, 30); // 例如，20x20 像素
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // 创建缩放后的图片
    UIImage *scaledImage = [self image:settingsImage resizedToSize:targetSize];
    settingsButton.frame = CGRectMake(0, 0, targetSize.width, targetSize.height); // 设置按钮大小
    [settingsButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [settingsButton setImage:scaledImage forState:UIControlStateNormal];
    
    // 确保图片在按钮中居中
    [settingsButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [settingsButton setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
    [settingsButton addTarget:self action:@selector(settingsTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *settingsButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.leftBarButtonItem = settingsButtonItem;
    // 将“免费试用”和“设置”按钮设置到导航栏的右侧.顺序从右到左
    self.navigationItem.rightBarButtonItems = @[ buyButtonItem];//@[settingsButtonItem, buyButtonItem];
    // ----------------------------------
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.collectionView registerClass:[TAlbumCollectionViewCell class] forCellWithReuseIdentifier:kCellConstant];
    [self updateCollectionViewLayout];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    
    // 注册默认cell的类（如果它们是自定义的）
    [self.collectionView registerClass:[TAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"MainAlbum"];
    [self.collectionView registerClass:[TAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"Trash"];
    
    // 初始化UIImagePickerController
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; // 设置来源为相册
    [self.imagePickerController setAllowsEditing:YES];
    [self setupViews];
    
}

- (void)updateCollectionViewLayout {
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    // 假设你想要的cell之间的间距和cell与边框的间距都是20
    CGFloat spacing = 15.0f;
    // 计算每个cell的宽度（考虑到间距）
    CGFloat itemWidth = (self.collectionView.frame.size.width - flowLayout.minimumInteritemSpacing) / 2.0;
    //CGFloat itemWidth = (self.collectionView.bounds.size.width - 2 * spacing - flowLayout.minimumInteritemSpacing) / 2.0;
    [flowLayout setItemSize:CGSizeMake(itemWidth, 100)]; // 设置cell的高度
    
    // 设置section的内边距，使得cell与边框的间距也是spacing
    flowLayout.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    // 设置collectionView的内边距（如果需要的话
    [self.collectionView setContentInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    
}


- (void)setupViews {
    //  获取屏幕宽度，并设置自定义视图的宽度与屏幕宽度相同
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.toolBar2 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, screenHeight - 44, screenWidth, 44)];
    [self.toolBar2 setCenterButtonFeatureEnabled:YES];
    [self.toolBar2 setTranslucent:YES];
    
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //  -------------------------- video --------------------------
    // 创建一个 UIButton
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    // 设置按钮的大小（根据需要调整）
    customButton.frame = CGRectMake(0, 0, 80, 40);
    
    // 设置按钮的图片
    UIImage *image = [UIImage imageNamed:@"picture"]; // 使用系统图标，或者使用你自己的图片
    
    // 目标尺寸（根据需要调整）
    CGSize targetSize = CGSizeMake(30, 30);
    // 例如，20x20 像素
    image = [self image:image resizedToSize:targetSize];
    
    [customButton setImage:image forState:UIControlStateNormal];
    
    // 设置按钮的文字
    [customButton setTitle:@"相薄" forState:UIControlStateNormal];
    
    // 调整图片和文字的位置（可选）
    customButton.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -30); // 根据需要调整插图
    customButton.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0);  // 根据需要调整插图
    
    // 为按钮添加目标动作（可选）
    [customButton addTarget:self action:@selector(albumTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    // 创建 UIBarButtonItem 并使用自定义视图
    UIBarButtonItem *albumButtonItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    //  -------------------------- video --------------------------
    // 创建一个 UIButton
    UIButton *contactorButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    // 设置按钮的大小（根据需要调整）
    contactorButton.frame = CGRectMake(0, 0, 80, 40);
    
    // 设置按钮的图片
    UIImage *contactorImage = [UIImage imageNamed:@"contacter"]; // 使用系统图标，或者使用你自己的图片
    
    contactorImage = [self image:contactorImage resizedToSize:targetSize];
    [contactorButton setImage:contactorImage forState:UIControlStateNormal];
    
    // 设置按钮的文字
    [contactorButton setTitle:@"联系人" forState:UIControlStateNormal];
    
    // 调整图片和文字的位置（可选）
    contactorButton.imageEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, -30); // 根据需要调整插图
    contactorButton.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0);  // 根据需要调整插图
    
    // 为按钮添加目标动作（可选）
    [contactorButton addTarget:self action:@selector(contactorTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:contactorButton];
    
    self.toolBar2.items = @[albumButtonItem, flexibleSpace, self.barButtonItem];
    [self.view addSubview:self.toolBar2];
    
    // 使用Masonry设置视图的约束
    [self.toolBar2 mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            // 对于iOS 11及以上版本，使用safeAreaLayoutGuide
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-44);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
        } else {
            // 对于iOS 11以下版本，使用topLayoutGuide和bottomLayoutGuide
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.and.right.equalTo(self.view);
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }
        
        // 可以设置其他约束，比如视图的高度
        //        make.height.equalTo(@44);
    }];
    
    self.toolBar2.centerButtonFeatureEnabled = YES;
    [self changeCenterButtonWithPaw:YES];

    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 根据屏幕的宽度来计算cell的大小
    CGFloat screenWidth = self.view.frame.size.width;
    // 例如，每个cell占据屏幕宽度的一半，高度为100
    return CGSizeMake(screenWidth * 0.4, screenWidth * 0.55);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TAlbumObject *albumObject = nil;
    if (indexPath.item == 0) {
        TAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MainAlbum" forIndexPath:indexPath];
        // 配置默认cell 1
        // 配置单元格的属性，包括传入自定义值
        albumObject = [self.dataArray objectAtIndex:indexPath.item];
        cell.albumName = albumObject.name;
        cell.albumId = albumObject.id;
        cell.detailLabel.text = [NSString stringWithFormat:@"%ld个文件", albumObject.photoCount];
        // 其他配置代码
        cell.titleLabel.text = cell.albumName;
        cell.delegate = self;
        return cell;
        
    } else if (indexPath.item == self.dataArray.count - 1) {
        TAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Trash" forIndexPath:indexPath];
        // 配置默认cell 2
        // 配置单元格的属性，包括传入自定义值
        
        albumObject = [self.dataArray objectAtIndex:indexPath.item];
        cell.albumName = albumObject.name;
        
        // 其他配置代码
        cell.titleLabel.text = cell.albumName;
        
        cell.delegate = self;
        return cell;
    } else {
        TAlbumCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellConstant forIndexPath:indexPath];
        // 配置单元格的属性，包括传入自定义值
        
        albumObject = [self.dataArray objectAtIndex:indexPath.item];
        cell.albumName = albumObject.name;
        cell.albumId = albumObject.id;
        cell.detailLabel.text = [NSString stringWithFormat:@"%ld个文件", albumObject.photoCount];
        // 其他配置代码
        cell.titleLabel.text = albumObject.name;
        cell.delegate = self;
        
        return cell;
    }
    
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // 在屏幕方向或大小变化时重新加载数据，以更新cell的大小
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView reloadData];
    } completion:nil];
}

- (void)changeCenterButtonWithPaw:(BOOL)isPaw
{
    NSString *imageName = isPaw ? @"CenterButtonIconPaw" : @"CenterButtonIconHeart";
    NSString *highlightedImageName = isPaw ? @"CenterButtonIconPawHighlighted" : @"CenterButtonIconHeartHighlighted";
    NSString *disabledImageName = isPaw ? @"CenterButtonIconPawDisabled" : @"CenterButtonIconHeartDisabled";
    UIImage *centerButtonImage = [UIImage imageNamed:imageName];
    UIImage *centerButtonImageHighlighted = [UIImage imageNamed:highlightedImageName];
    UIImage *centerButtonImageDisabled = [UIImage imageNamed:disabledImageName];
    EEToolbarCenterButtonItem *centerButtonItem = [[EEToolbarCenterButtonItem alloc] initWithImage:centerButtonImage highlightedImage:centerButtonImageHighlighted disabledImage:centerButtonImageDisabled target:self action:@selector(didTapCenterButton:)];
    
    self.toolBar2.centerButtonOverlay.buttonItem = centerButtonItem;
    
    
}


- (void)contactorTapped:(id)sender {
    
}

- (void)didTapCenterButton:(id)sender
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.createItemView = [[TCreateAlbumPhotoView alloc]initWithFrame:CGRectMake(0, 0 , screenWidth, screenHeight)];
    
    [[self.createItemView albumButton] addTarget:self action:@selector(albumTapped:) forControlEvents:UIControlEventTouchUpInside];
    // 添加弹出视图到窗口
    [UIApplication.sharedApplication.keyWindow addSubview:self.createItemView];
    // 4. 添加点击事件以隐藏弹出视图
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopupView)];
    [self.createItemView addGestureRecognizer:tapGesture];
    
}

- (void)barButtonItemClicked:(id)sender {
    // 处理点击事件
}

- (void)showAlbumClick:(TAlbumCollectionViewCell *)cell didTapButton:(NSString *)albumName {
    
    // 创建标题标签并包装到 UIView 中
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)]; // 设置标签大小和位置
    titleLabel.text = albumName;
    titleLabel.font = [UIFont systemFontOfSize:30.0];
    titleLabel.textColor = [UIColor blackColor]; // 白色文字
    titleLabel.textAlignment = NSTextAlignmentCenter; // 居中对齐
    
    UIView *titleView = [[UIView alloc] initWithFrame:titleLabel.frame];
    [titleView addSubview:titleLabel];
    
    AlbumSettingViewController *controller = [[AlbumSettingViewController alloc]initWithAlbumId:cell.albumId andAlbumName:cell.albumName];
//    [controller albumInfo:cell.albumId andAlbumName:cell.albumName];
    controller.updateAlbumCountBlock = ^(NSInteger count) {
        [cell.detailLabel setText:[NSString stringWithFormat:@"%ld个文件", count]];
    };
    controller.navigationItem.titleView = titleView;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相簿" style:UIBarButtonItemStylePlain target:nil action:nil];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:controller animated:YES];
    
}

/**
 moreDots事件
 */
- (void)showAlbumToosClick:(TAlbumCollectionViewCell *)cell {
    AlbumSettingViewController *controller = [[AlbumSettingViewController alloc]init];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)settingsTapped:(UIButton *)sender {
    SettingViewController *controller = [[SettingViewController alloc]init];
    controller.navigationItem.title = @"设置";
    [self.navigationController pushViewController:controller animated:YES];
}

- (UIImage *)image:(UIImage *)image resizedToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)dismissPopupView {
    UIView *popupView = [UIApplication.sharedApplication.keyWindow.subviews lastObject];
    if ([popupView isKindOfClass:[UIView class]]) {
        [popupView removeFromSuperview];
    }
}

/**
 按钮事件,新建相册
 */
- (void)albumTapped:(id)sender {
    // 创建并配置UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"新建相册" message:@"请输入相册名" preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加文本输入框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"相册名";
    }];
    
    // 添加操作按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // 处理用户点击确定按钮后的逻辑
        UITextField *textField = alertController.textFields.firstObject;
        NSString *inputText = textField.text;
        [self.storage insertAlbum:inputText];
        [self.createItemView removeFromSuperview];
        [self reloadDataFromDatabase];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    // 呈现对话框
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reloadDataFromDatabase {
    // 获取当前cell的数量
    
    TAlbumObject *albumObj = [self.storage getLastestAlbumResultSet];
    NSString *name = albumObj.name;
    NSInteger dataArrayCount = [self.dataArray count];
    [self.dataArray insertObject:albumObj atIndex:dataArrayCount - 1];
    // 使用performBatchUpdates:completion:来进行局部更新
    @try {
        // 使用performBatchUpdates:completion:来进行局部更新
        [self.collectionView performBatchUpdates:^{
            // 插入新的cell
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:dataArrayCount - 1 inSection:0];
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            
        } completion:nil];
    } @catch (NSException *exception) {
        
        // 捕获并处理异常
        NSLog(@"Caught an exception: %@", exception);
    }
}


- (void)freeTrialTapped:(id)sender {
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage]; // 获取编辑后的照片
    //    self.imageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateAlbumCount:(NSInteger)albumCount {
    
}
@end
