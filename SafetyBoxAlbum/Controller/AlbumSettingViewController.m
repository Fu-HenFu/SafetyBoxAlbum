//
//  AlbumSettingViewController.m
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2024/12/25.
//

#import "AlbumSettingViewController.h"
#import "Masonry/Masonry.h"

#import "TCreatePhotoView.h"

@interface AlbumSettingViewController ()

@property (nonatomic, strong) UIButton *addButton;
@property (strong, nonatomic) TCreatePhotoView *createItemView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) CGFloat screenWidth;
@property (assign, nonatomic) CGFloat screenHeight;


@end

@implementation AlbumSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // 初始化数据列表
    self.dataArray = [NSMutableArray array];
    
    // 初始化 UICollectionViewFlowLayout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical; // 设置滚动方向为水平
    
    CGFloat cellWidth = (self.screenWidth - 3 * 10) / 4;
    
    layout.itemSize = CGSizeMake(cellWidth, cellWidth);
    // 初始化 UICollectionView
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    // 注册单元格类
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
    // 将 UICollectionView 添加到视图
    [self.view addSubview:self.collectionView];
    
    CGSize targetSize = CGSizeMake(40, 40); // 例如，20x20 像素
    UIImage *addImage = [UIImage imageNamed:@"CenterButtonIconPaw"];
    
    self.addButton = [[UIButton alloc]init];
    [self.addButton setImage:addImage forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(didTapCenterButton:) forControlEvents:UIControlEventTouchUpInside];
    // 调整图片和文字的位置（可选）
    self.addButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0); // 根据需要调整插图
    [self.view addSubview:self.addButton];
    CGFloat buttonHeight = [addImage size].width; // 设置按钮高度为30点
    // 使用Masonry设置视图的约束
    @try {
        [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                // 对于iOS 11及以上版本，使用safeAreaLayoutGuide
                make.bottom
                    .equalTo(self.view.mas_safeAreaLayoutGuideBottom)
                    .offset(0);
                
                make.centerX.equalTo(self.view.mas_centerX);
                
                make.height.equalTo(@(buttonHeight));
                make.width.equalTo(@(buttonHeight));
            } else {
                // 对于iOS 11以下版本，使用topLayoutGuide和bottomLayoutGuide
                make.top.equalTo(self.mas_topLayoutGuideBottom);
                make.left.and.right.equalTo(self.view);
                make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
            }
            
        }];
    } @catch (NSException *exception) {
        // 捕获并处理异
        NSLog(@"Caught an exception: %@", exception);
    }
    
    // 初始化UIImagePickerController
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    
}

- (void)closeAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapCenterButton:(UIButton *)sender
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (self.createItemView == nil) {
        self.createItemView = [[TCreatePhotoView alloc]initWithFrame:CGRectMake(0, 0 , screenWidth, screenHeight)];
        [self.createItemView.pictureButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self.createItemView.cameraButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    //    [[self.createItemView albumButton] addTarget:self action:@selector(albumTapped:) forControlEvents:UIControlEventTouchUpInside];
    // 添加弹出视图到窗口
    [UIApplication.sharedApplication.keyWindow addSubview:self.createItemView];
    // 4. 添加点击事件以隐藏弹出视图
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopupView)];
    [self.createItemView addGestureRecognizer:tapGesture];
    
}

/**
 * 点击任何空白处,即可关闭弹出页面
 *
 * @param a 第一个整数
 * @param
 * @return
 */
- (void)dismissPopupView {
    UIView *popupView = [UIApplication.sharedApplication.keyWindow.subviews lastObject];
    if ([popupView isKindOfClass:[UIView class]]) {
        [popupView removeFromSuperview];
    }
}

- (UIImage *)image:(UIImage *)image resizedToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)selectPhoto:(id)sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; // 设置来源为相册
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}


- (void)takePhoto:(id)sender {
    // 检查相机是否可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 设置 sourceType 为相机
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // 显示 UIImagePickerController
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    } else {
        NSLog(@"相机不可用");
        // 可以在这里显示一个提示信息，告诉用户相机不可用
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    // 设置单元格内容
    cell.backgroundColor = [UIColor lightGrayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.dataArray[indexPath.row];
    [cell.contentView addSubview:label];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate 方法

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item at index path: %@", indexPath);
}


/**
 * chosen picture
 *
 * @param
 * @return
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage]; // 获取编辑后的照片
    // 保存照片到沙盒
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *imagePath = [documentsPath stringByAppendingPathComponent:@"selectedImage.png"];
    NSData *imageData = UIImagePNGRepresentation(selectedImage); // 或者使用 UIImageJPEGRepresentation
    [imageData writeToFile:imagePath atomically:YES];
    
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    if (imageURL) {
        // 提示用户是否删除相册中的照片
        [self askUserToDeletePhotoWithURL:imageURL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)askUserToDeletePhotoWithURL:(NSURL *)imageURL {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"删除照片"
                                                                         message:@"您是否希望删除相册中的这张照片？"
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self deletePhotoWithURL:imageURL];
                                                         }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];

    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deletePhotoWithURL:(NSURL *)imageURL {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAsset *asset = [PHAsset fetchAssetsWithALAssetURLs:@[imageURL] options:nil].firstObject;
        if (asset) {
            [PHAssetChangeRequest deleteAssets:@[asset]];
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"照片删除成功");
        } else {
            NSLog(@"照片删除失败: %@", error);
        }
    }];
}

@end
