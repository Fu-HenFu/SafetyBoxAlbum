//
//  AlbumSettingViewController.m
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2024/12/25.
//

#import "AlbumSettingViewController.h"
#import "Masonry/Masonry.h"
#import "LGPhoto/Classes/LGPhoto.h"
#import "TImageCollectionViewCell.h"
#import "TCreatePhotoView.h"
#import "TDeleteView.h"
#import "TPictureAudioObject.h"
#import "GlobalDefine.h"
#import "TStorage.h"
#import "TPictureDetailViewController.h"

@interface AlbumSettingViewController ()

@property (nonatomic, strong) UIButton *addButton;
@property (strong, nonatomic) TCreatePhotoView *createItemView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) NSMutableArray<TPictureAudioObject *> *dataArray;
@property (strong, nonatomic) NSMutableArray *originImageArray;
@property (strong, nonatomic) NSMutableArray *fullResolutionImage;
@property (assign, nonatomic) CGFloat screenWidth;
@property (assign, nonatomic) CGFloat screenHeight;

@property (nonatomic, copy) NSArray *titleArray;
@property (nonatomic, strong)NSMutableArray *LGPhotoPickerBrowserPhotoArray;
@property (nonatomic, strong)NSMutableArray *LGPhotoPickerBrowserURLArray;
@property (nonatomic, assign) LGShowImageType showType;

@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong) NSMutableArray *imageUrlArray;
@property (nonatomic, assign) NSInteger albumId;
@property (nonatomic, strong) NSString *albumName;


@property (nonatomic, strong) TStorage *storage;
@property (nonatomic, strong) NSString *documentsPath;

@end

@implementation AlbumSettingViewController

- (instancetype)initWithAlbumId:(NSInteger)albumId andAlbumName:(NSString *)albumName
{
    self = [super init];
    if (self) {
        // 初始化数据列表
        self.dataArray = [NSMutableArray array];
        self.originImageArray = [NSMutableArray array];
        self.fullResolutionImage = [NSMutableArray array];
        self.albumId = albumId;
        self.albumName = albumName;
        self.storage = [TStorage shareStorage];
        [self.dataArray addObjectsFromArray:[self.storage queryPicture:USEFUL_STATE_TYPE andAlbumId:self.albumId]];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    
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
    [self.collectionView registerClass:[TImageCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    
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
                make.bottom .equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(0);
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
    
    [self prepareForPhotoBroswerWithImage];
    [self prepareForPhotoBroswerWithURL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chosenNotification:) name:PICKER_TAKE_DONE object:nil];
}

- (void)closeAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 点击弹出导入照片的方式,相册或拍照
 */
- (void)didTapCenterButton:(UIButton *)sender
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//    if (self.createItemView == nil) {
        self.createItemView = [[TCreatePhotoView alloc]initWithFrame:CGRectMake(0, 0 , screenWidth, screenHeight)];
        [self.createItemView.pictureButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self.createItemView.cameraButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
//    }
    
    
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

/**
 使用相册选择照片
 */
- (void)selectPhoto:(id)sender {
    
    [self presentPhotoPickerViewControllerWithStyle:LGShowImageTypeImagePicker];

}

/**
使用照相机拍照
 */
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    // 设置单元格的图片
    NSString *imageName = [self.dataArray[indexPath.item] name];
    
    if (imageName) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *filePath = [[documentsDirectory stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:imageName];
        UIImage *cellImage = [UIImage imageNamed:filePath];
        cell.imageView.image = cellImage;//self.dataArray[indexPath.item];

    }

    return cell;
}
// 

#pragma mark - UICollectionViewDelegate 方法

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item at index path: %@", indexPath);
    
    TImageCollectionViewCell *cell = (TImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    // 设置单元格的图片
    NSString *imageName = [self.dataArray[indexPath.item] name];
    
    if (imageName) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:imageName];
        UIImage *cellImage = [UIImage imageNamed:filePath];
        
        // 准备跳转到全屏图片展示视图控制器
        //        UIImage *selectedImage = self.images[indexPath.item];
        TPictureDetailViewController *controller = [[TPictureDetailViewController alloc]init];
        controller.image = cellImage;
//        [self.navigationController pushViewController:controller animated:YES];
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:^{
                    
        }];
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        NSDictionary *info = (NSDictionary *)sender;
        UIImage *image = info[@"image"];
        TPictureDetailViewController *detailVC = segue.destinationViewController;
        detailVC.image = image;
    }
}


/**
 请求删除相册中的照片
 */
- (void)askUserToDeletePhotoWithURL:(NSArray *)imageURLs {
    [self deletePhotoWithURL:imageURLs];

}	

/**
 删除照片
 */
- (void)deletePhotoWithURL:(NSArray *)imageURL {
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        NSMutableArray *urlArray = [NSMutableArray array];
        for (NSURL *url in imageURL) {
            PHAsset *asset = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil].firstObject;
            if (asset) {
                [PHAssetChangeRequest deleteAssets:@[asset]];
            }
        }
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"照片删除成功");
        } else {
            NSLog(@"照片删除失败: %@", error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self dismissPopupView];
        });
        
    }];
}


/**
 给照片浏览器传image的时候先包装成LGPhotoPickerBrowserPhoto对象
 */
- (void)prepareForPhotoBroswerWithImage {
    self.LGPhotoPickerBrowserPhotoArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; i++) {
        LGPhotoPickerBrowserPhoto *photo = [[LGPhotoPickerBrowserPhoto alloc] init];
        photo.photoImage = [UIImage imageNamed:[NSString stringWithFormat:@"broswerPic%d.jpg",i]];
        [self.LGPhotoPickerBrowserPhotoArray addObject:photo];
    }
}

/**
 给照片浏览器传URL的时候先包装成LGPhotoPickerBrowserPhoto对象
 */
- (void)prepareForPhotoBroswerWithURL {
    self.LGPhotoPickerBrowserURLArray = [[NSMutableArray alloc] init];
    
    LGPhotoPickerBrowserPhoto *photo = [[LGPhotoPickerBrowserPhoto alloc] init];
    photo.photoURL = [NSURL URLWithString:@"http://img.ivsky.com/img/bizhi/slides/201511/11/december.jpg"];
    [self.LGPhotoPickerBrowserURLArray addObject:photo];
    
    LGPhotoPickerBrowserPhoto *photo1 = [[LGPhotoPickerBrowserPhoto alloc] init];
    photo1.photoURL = [NSURL URLWithString:@"http://h.hiphotos.baidu.com/image/pic/item/267f9e2f0708283890f56e02bb99a9014c08f128.jpg"];
    [self.LGPhotoPickerBrowserURLArray addObject:photo1];
    
    LGPhotoPickerBrowserPhoto *photo2 = [[LGPhotoPickerBrowserPhoto alloc] init];
    photo2.photoURL = [NSURL URLWithString:@"http://a.hiphotos.baidu.com/image/pic/item/b219ebc4b74543a9fa0c4bc11c178a82b90114a3.jpg"];
    [self.LGPhotoPickerBrowserURLArray addObject:photo2];
    
    LGPhotoPickerBrowserPhoto *photo3 = [[LGPhotoPickerBrowserPhoto alloc] init];
    photo3.photoURL = [NSURL URLWithString:@"http://c.hiphotos.baidu.com/image/pic/item/024f78f0f736afc33b1dbe65b119ebc4b7451298.jpg"];
    [self.LGPhotoPickerBrowserURLArray addObject:photo3];
    
    LGPhotoPickerBrowserPhoto *photo4 = [[LGPhotoPickerBrowserPhoto alloc] init];
    photo4.photoURL = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/pic/item/77094b36acaf2edd481ef6e78f1001e9380193d5.jpg"];
    [self.LGPhotoPickerBrowserURLArray addObject:photo4];
}

- (void)presentPhotoPickerViewControllerWithStyle:(LGShowImageType)style {
    LGPhotoPickerViewController *pickerVc = [[LGPhotoPickerViewController alloc] initWithShowType:style];
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.maxCount = 100;   // 最多能选9张图片
    pickerVc.delegate = self;
//    pickerVc.nightMode = YES;//夜间模式
    self.showType = style;
    [pickerVc showPickerVc:self];
}

// 处理通知的方法
- (void)chosenNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    // 处理通知
    NSArray *selectedArr = userInfo[@"selectAssets"];
    NSUInteger insertIndex = 0;
    NSMutableArray *tempDataArray = [NSMutableArray array];


}

#pragma mark - LGPhotoPickerViewControllerDelegate

- (void)pickerViewControllerDoneAsstes:(NSArray <LGPhotoAssets *> *)assets isOriginal:(BOOL)original{
    
    self.assetsArray = [NSMutableArray array];
    [self.assetsArray addObjectsFromArray:assets];
    
    self.imageUrlArray = [NSMutableArray array];
    for (LGPhotoAssets *asset in assets) {
        NSURL *imageUrl = asset.assetURL;
        
        [self.imageUrlArray addObject:imageUrl];
        UIImage *originImage = asset.originImage;
        UIImage *thumbImage = asset.thumbImage;
        
    }
    //  删除相册中的照片
    [self excuteDeleteFromAlbum:nil];
    
    NSInteger num = (long)assets.count;
    NSString *isOriginal = original? @"YES":@"NO";
    
    UIImage *image = assets[0].thumbImage;
    NSString *message = @"这是一个自定义提示框！";

}

/**
 提示是否删除相册中的照片,并保存照片到本地
 */
- (void)excuteDeleteFromAlbum:(UIButton *)sender {
    [self translateAlbumIntoAppDir:self.assetsArray withImageInfo: self.imageUrlArray];
    if (self.imageUrlArray.count > 0) {
        // 提示用户是否删除相册中的照片
        [self askUserToDeletePhotoWithURL:self.imageUrlArray];
    }
}

/**
 把照片转移到app中的目录
 */
- (void)translateAlbumIntoAppDir: (NSArray<LGPhotoAssets *> *)selectedImage withImageInfo: (NSArray *)urlArray {
    
    NSMutableArray *tempDataArray = [NSMutableArray array];
    // 保存照片到沙盒
    self.documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    for (LGPhotoAssets *asset in selectedImage) {
        
        PHAsset *phasset = [PHAsset fetchAssetsWithALAssetURLs:@[asset.assetURL] options:nil].firstObject;
        NSString *imgIdentifier = @"";
        if (phasset) {
            
            imgIdentifier = [NSString stringWithFormat:@"%@.PNG", [phasset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
            
            NSString *imagePath = [self.documentsPath stringByAppendingPathComponent: imgIdentifier];
            NSData *imageData = UIImagePNGRepresentation(asset.originImage); // 或者使用 UIImageJPEGRepresentation
            BOOL flag = [imageData writeToFile:imagePath atomically:YES];
            
            NSString *thumbDirPah = [self.documentsPath stringByAppendingPathComponent: @"thumb"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath:thumbDirPah]) {
                NSError *error;
                [fileManager createDirectoryAtPath:thumbDirPah withIntermediateDirectories:YES attributes:nil error:&error];
                if (error) {
                    NSLog(@"Error occur");
                }
            } else {
                
            }
            
            NSString *thumbImagePath = [thumbDirPah stringByAppendingPathComponent:imgIdentifier];
            NSData *thumbImageData = UIImagePNGRepresentation(asset.thumbImage);
            BOOL flag2 = [thumbImageData writeToFile:thumbImagePath atomically:YES];
            
            //  照片转存成功
            if (flag) {
                TPictureAudioObject *pictureObject = [[TPictureAudioObject alloc]init];
                [pictureObject setName:imgIdentifier];
                [pictureObject setPath:imagePath];
                [pictureObject setThumbPath:thumbImagePath];
                [pictureObject setType: PICTURE_TYPE];
                [pictureObject setState: USEFUL_STATE_TYPE];
                [pictureObject setAlbumName: self.albumName];
                [pictureObject setAlbumId: self.albumId];
                [self addRecordInDB:pictureObject];
                
                [tempDataArray addObject:pictureObject];
                
            }
            
            NSLog(@" ImagePath %@", imagePath);
        }
        NSLog(@" imgggg %ld", [selectedImage indexOfObject:asset]);
        if ([selectedImage indexOfObject:asset] == selectedImage.count - 1 ) {
            NSInteger totalPhotoCount = self.dataArray.count + selectedImage.count;
            [self updateAlbumPhotoCount:totalPhotoCount andAlbumId:self.albumId];
        }
    }
    
    int insertIndex = self.dataArray.count;
    @try {
        // 更新数据源
        [self.dataArray insertObjects:tempDataArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(insertIndex, tempDataArray.count)]];
        [self.collectionView performBatchUpdates:^{
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (NSUInteger i = 0; i < tempDataArray.count; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForItem: insertIndex + i inSection:0]];
            }
            [self.collectionView insertItemsAtIndexPaths:indexPaths];

        } completion:^(BOOL finished) {
            if (self.updateAlbumCountBlock) {
                self.updateAlbumCountBlock(self.dataArray.count);
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"Exception Occur %@", exception.description);
    }

}

- (void)addRecordInDB: (TPictureAudioObject *) pictureObject{
    BOOL flag = [self.storage insertPicture:pictureObject];
 
    NSLog(@"insert flag %d", flag);
}

- (void)updateAlbumPhotoCount:(NSInteger)photoCount andAlbumId:(NSInteger)albumId {
    [self.storage updateAlbumPhotoCount:albumId andCount:photoCount];

}

- (void)albumInfo:(NSInteger)albumId andAlbumName:(NSString *)albumName{
    self.albumId = albumId;
    self.albumName = albumName;
}

//- (void)handleImageTap3:(TImageCollectionViewCell *)cell {
//    CGFloat cellWidth = (self.screenWidth - 3 * 10) / 4;
//    
//  
//    
////    if (CGRectEqualToRect(cell.frame, self.original ImageViewFrame)) {
//        // 放大到全屏
//        [UIView animateWithDuration:0.3 animations:^{
//            view.frame = self.view.bounds;
//            self.scrollView.contentSize = self.view.bounds.size; // 调整 contentSize 以支持滚动
//        }];
////    } else {
////        // 恢复原状
////        [UIView animateWithDuration:0.3 animations:^{
////            view.frame = self.originalImageViewFrame;
////            self.scrollView.contentSize = self.view.bounds.size; // 恢复 contentSize
////        }];
////    }
//
//}
//
//- (void)handleImageTap:(UITapGestureRecognizer *)sender {
//    UIView *view = sender.view;
// 
//    // 切换到全屏模式或恢复原状
//    if (CGRectEqualToRect(view.frame, self.originalImageViewFrame)) {
//        // 放大到全屏
//        [UIView animateWithDuration:0.3 animations:^{
//            view.frame = self.view.bounds;
//            self.scrollView.contentSize = self.view.bounds.size; // 调整 contentSize 以支持滚动
//        }];
//    } else {
//        // 恢复原状
//        [UIView animateWithDuration:0.3 animations:^{
//            view.frame = self.originalImageViewFrame;
//            self.scrollView.contentSize = self.view.bounds.size; // 恢复 contentSize
//        }];
//    }
//}

@end
