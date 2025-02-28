//
//  AlbumSettingViewController.m
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2024/12/25.
//

#import "AlbumSettingViewController.h"
#import "Masonry/Masonry.h"
#import "TImageCollectionViewCell.h"
#import "TCreatePhotoView.h"
#import "TDeleteView.h"
#import "TPictureAudioObject.h"
#import "GlobalDefine.h"
#import "TStorage.h"
#import "TPictureDetailViewController.h"
#import "TMultiView.h"

#import <SCLAlertView.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import "TZImagePicker/TZImageUploadOperation.h"
#import "Utils.h"
#import "TSelectAlbumViewController.h"

#define EditBottomViewHeight 80

@interface AlbumSettingViewController () <TZImagePickerControllerDelegate> {
    
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    NSMutableArray *_selectedEditAssets;    //  选择照片时,选中的照片对象
    BOOL _isSelectOriginalPhoto;
    BOOL _isAllowEditVideo;
    
    CGFloat _itemWH;
    CGFloat _margin;
    BOOL _isEdit;
}

@property (nonatomic, strong) NSOperationQueue *operationQueue;
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

@property (nonatomic, strong) NSMutableArray *assetsArray;
@property (nonatomic, strong) NSMutableArray *imageUrlArray;
@property (nonatomic, assign) NSInteger albumId;
@property (nonatomic, strong) NSString *albumName;

@property (nonatomic, strong) TStorage *storage;
@property (nonatomic, strong) NSString *documentsPath;

@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic, strong) SCLAlertView *waitingAlert;
@property (nonatomic, strong) SCLAlertView *successAlert;
@property (nonatomic, strong) SCLAlertView *warningAlert;
@property (nonatomic, strong) UIBarButtonItem *rightItem;

@property (nonatomic, strong) TMultiView *editBottomView;


@property (nonatomic, strong) TSelectAlbumViewController *selectedAlbumController;

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
        _isEdit = NO;
        self.albumId = albumId;
        self.albumName = albumName;
        self.rightItem = [[UIBarButtonItem alloc]initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(multiplySelectAction:)];
        [self.navigationItem setRightBarButtonItem:self.rightItem];
        self.storage = [TStorage shareStorage];
        [self refetchDataFromDatabase];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageManager = [[PHCachingImageManager alloc] init];
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

    
    self.editBottomView = [[TMultiView alloc]initWithFrame:CGRectMake(0, 0, _screenWidth, 0)];
    
    [self.view addSubview:self.editBottomView];
    
    [self.editBottomView setBackgroundColor:[UIColor colorWithWhite:244/255.0 alpha:1]];
    [self.editBottomView.moveButton addTarget:self action:@selector(movePictureToAnotherAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.editBottomView.deleteButton addTarget:self action:@selector(deletePictureFromAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.editBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    // 对于iOS 11及以上版本，使用safeAreaLayoutGuide
                    make.top.equalTo(self.collectionView.mas_bottom).offset(0);
                    make.centerX.equalTo(self.view.mas_centerX);
                    make.height.equalTo(@(EditBottomViewHeight));
                    make.width.equalTo(@(self.screenWidth));
                } else {
                    // 对于iOS 11以下版本，使用topLayoutGuide和bottomLayoutGuide
                    make.top.equalTo(self.mas_topLayoutGuideBottom);
                    make.left.and.right.equalTo(self.view);
                    make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
                }
    }];
    
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    // 重新从数据库获取数据
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[self.storage queryPicture:USEFUL_STATE_TYPE andAlbumId:self.albumId]];
    
    [self.collectionView reloadData];
    [self scrollToLastItem];
//    [self refetchDataFromDatabase];
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
    [self dismissPopupView];
    [self pushImagePickerController];
//    [self presentPhotoPickerViewControllerWithStyle:LGShowImageTypeImagePicker];

}

/**
使用照相机拍照
 */
- (void)takePhoto:(id)sender {
    [self dismissPopupView];
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    
    // 设置单元格的图片
    NSString *imageName = [self.dataArray[indexPath.item] name];
    [cell setMultiSelected:_isEdit];
    
    if (imageName) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *filePath = [[documentsDirectory stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:imageName];	
        UIImage *cellImage = [UIImage imageNamed:filePath];
        cell.imageView.image = cellImage;

    }

    return cell;
}
// 

#pragma mark - UICollectionViewDelegate 方法

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected item at index path: %@", indexPath);
    
    TImageCollectionViewCell *cell = (TImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (_isEdit) {
        if ([_selectedEditAssets containsObject: self.dataArray[indexPath.item]]) {
            [_selectedEditAssets removeObject:self.dataArray[indexPath.item]];
            [cell selectedImage:NO];
            return;
        }
        [_selectedEditAssets addObject: self.dataArray[indexPath.item]];
        [cell selectedImage:YES];
        return;
    }
    
    
    // 设置单元格的图片
    NSString *imageName = [self.dataArray[indexPath.item] name];
    
    if (imageName) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:imageName];
        UIImage *cellImage = [UIImage imageNamed:filePath];

        
        // 准备跳转到全屏图片展示视图控制器
        //        UIImage *selectedImage = self.images[indexPath.item];
        TPictureDetailViewController *controller = [[TPictureDetailViewController alloc]initWithIndexPath:indexPath assetsFetchResults:self.dataArray imageManager:self.imageManager andAlbumId:self.albumId andAlbumName:self.albumName];
        controller.image = cellImage;
        controller.thumbSize = cellImage.size;

        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:^{
                    
        }];
    }

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TImageCollectionViewCell *cell = (TImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (_isEdit) {
        [_selectedEditAssets removeObject:self.dataArray[indexPath.item]];
        [cell selectedImage:NO];
    }
    NSLog(@"***********************");
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
- (void)askUserToDeletePhotoWithURL:(NSArray *)assets {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        NSMutableArray *urlArray = [NSMutableArray array];
        for (PHAsset *asset in assets) {

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
        
    }];

}

// 处理通知的方法
- (void)chosenNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    // 处理通知
    NSArray *selectedArr = userInfo[@"selectAssets"];
    NSUInteger insertIndex = 0;
    NSMutableArray *tempDataArray = [NSMutableArray array];


}

/**
 等待提示框
 */
- (void)showWaiting
{
    self.waitingAlert = [[SCLAlertView alloc] init];
    
    self.waitingAlert.showAnimationType = SCLAlertViewShowAnimationSlideInToCenter;
    self.waitingAlert.hideAnimationType = SCLAlertViewHideAnimationSlideOutFromCenter;
    
    self.waitingAlert.backgroundType = SCLAlertViewBackgroundTransparent;
    
    [self.waitingAlert showWaiting:self title:@"稍等..."
            subTitle:@"正在导入相册,请等待一下" closeButtonTitle:nil duration:0];
    
 
}

- (void)showSuccess:(nullable NSString *)albumName {
    [self scrollToLastItem];
    self.successAlert = [[SCLAlertView alloc] initWithNewWindow];

    self.successAlert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [NSBundle mainBundle].resourcePath]];

    [self.successAlert addButton:@"好的" actionBlock:^{
        [self scrollToLastItem];
        
        if (_selectedAssets.count > 0) {
            // 提示用户是否删除相册中的照片
            [self askUserToDeletePhotoWithURL:_selectedAssets];
        }
    }];
    
    
    [self.successAlert showSuccess:@"完成" subTitle:[NSString stringWithFormat:@"已移入相册%@", albumName] closeButtonTitle:nil duration:0.0f];

}



/// 更新collectionView的cell - 新增cell
/// - Parameter pictureObject: 新增的TPictureAudio对象
- (void)updateCollectionViewDataArrayWithOnePhoto:(TPictureAudioObject *)pictureObject {
    int insertIndex = self.dataArray.count;
    [self.dataArray addObject:pictureObject];
    [self.collectionView performBatchUpdates:^{
            
            NSMutableArray *indexPaths = [NSMutableArray array];
        
            [indexPaths addObject:[NSIndexPath indexPathForItem:insertIndex inSection:0]];
         
        
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
        } completion:^(BOOL finished) {
//            if (self.updateAlbumCountBlock) {
//                self.updateAlbumCountBlock(self.dataArray.count);
//            }
        }];
}

- (void)addRecordInDB: (TPictureAudioObject *) pictureObject{
    BOOL flag = [self.storage insertPicture:pictureObject];
    
}

- (void)updateAlbumPhotoCount:(NSInteger)photoCount andAlbumId:(NSInteger)albumId {
    [self.storage updateAlbumPhotoCount:albumId andCount:photoCount];

}

/// 更新Album表的封面照片地址
/// - Parameter imagePath: 照片地址
- (void)updateAlbumLastestImagePath:(NSString *)imagePath {
    [self.storage updateAlbumLastestImagePath:imagePath albumId:self.albumId];
}

- (void)albumInfo:(NSInteger)albumId andAlbumName:(NSString *)albumName{
    self.albumId = albumId;
    self.albumName = albumName;
}

/**
 查询数据库,获取照片
 */
- (void)refetchDataFromDatabase {
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[self.storage queryPicture:USEFUL_STATE_TYPE andAlbumId:self.albumId]];
    
    [self.collectionView reloadData];
    [self scrollToLastItem];
    
//    if (self.updateAlbumCountBlock) {
//        self.updateAlbumCountBlock(self.dataArray.count);
//    }
}

- (void)scrollToLastItem {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections > 0) {
        NSInteger numberOfItemsInLastSection = [self.collectionView numberOfItemsInSection:numberOfSections - 1];
        if (numberOfItemsInLastSection > 0) {
            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:numberOfItemsInLastSection - 1 inSection:numberOfSections - 1];
            [self.collectionView scrollToItemAtIndexPath:lastIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }
    }
}

- (void)pushImagePickerController {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:40 delegate:self];

    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
//    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//
//    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


/// 使用照相机后,返回拍摄的照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        if (self.documentsPath.length == 0) {
            self.documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        }
        
        NSString *identifierStr = [NSString stringWithFormat:@"%@.PNG", generateUniqueString()];
        NSString *imagePath = [self.documentsPath stringByAppendingPathComponent:identifierStr];
            
        NSData *imageData = UIImagePNGRepresentation(image);
        [imageData writeToFile:imagePath atomically:YES];
        
        NSString *thumbFilePath = [[self.documentsPath stringByAppendingPathComponent:@"thumb"] stringByAppendingPathComponent:identifierStr];
        
        CGSize thumbnailSize = CGSizeMake(300, 300);
        UIImage *thumbnailImage = [self resizeImage:image withSize:thumbnailSize];
        
        NSData *thumbImageData = UIImagePNGRepresentation(thumbnailImage);
        [thumbImageData writeToFile:thumbFilePath atomically:YES];
            
        NSLog(@"Image saved to %@", imagePath);
            
        
        TPictureAudioObject *pictureObject = [[TPictureAudioObject alloc]init];
        [pictureObject setName:identifierStr];
        [pictureObject setPath:imagePath];
        [pictureObject setThumbPath:thumbFilePath];
        [pictureObject setType:PICTURE_TYPE];
        [pictureObject setState: USEFUL_STATE_TYPE];
        [pictureObject setAlbumName: self.albumName];
        [pictureObject setAlbumId: self.albumId];
        [self addRecordInDB:pictureObject];
        //  update Album表
        NSInteger totalPhotoCount = self.dataArray.count + 1;
        [self updateAlbumPhotoCount:totalPhotoCount andAlbumId:self.albumId];

        
//        dispatch_async(dispatch_get_main_queue(), ^{
            [picker dismissViewControllerAnimated:YES completion:nil];
//        });
//    });

    
}


/// 为图片新建一个指定尺寸的新图片
/// - Parameters:
///   - image: 旧图片
///   - size: 新图片的尺寸
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
    
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    NSLog(@"info!!!!!!!!!!!! %@", infos);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self movePhotoInAppDir:photos sourceAssets:assets isSelectOriginalPhoto:isSelectOriginalPhoto];
        
    });
    
    [self showWaiting];
    

    
}

/// update 数据表,把插入薄中选中的照片中选中的新的照片和更新照片总数
/// - Parameters:
///   - photos: 选中的uiimage 对象队列
///   - assets: 选中的asset 对象队列
///   - isSelectOriginalPhoto: 是否选择原图
- (void)movePhotoInAppDir:(NSArray<UIImage *> *)photos  sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
//    [_collectionView reloadData];
    
    NSString *imgIdentifier = @"";
    self.documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *lastestImagePathStr = nil;
    TPictureAudioObject *pictureObject = NULL;
    for (int i = 0; i < assets.count; i++) {
        PHAsset *asset = assets[i];
        imgIdentifier = [NSString stringWithFormat:@"%@.PNG", [asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
        NSString *imagePath = [self.documentsPath stringByAppendingPathComponent: imgIdentifier];
        NSString *thumbDirPah = [self.documentsPath stringByAppendingPathComponent: @"thumb"];
        
        //  保证thumb照片有存放文件夹
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:thumbDirPah]) {
            NSError *error;
            [fileManager createDirectoryAtPath:thumbDirPah withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"Error occur");
            }
        }
        //  把thumb 照片存入指定文件夹
        NSString *thumbImagePath = [thumbDirPah stringByAppendingPathComponent:imgIdentifier];
        
        NSData *thumbImageData = UIImagePNGRepresentation(photos[i]);
        BOOL thumbFlag = [thumbImageData writeToFile:thumbImagePath atomically:YES];
        NSString *thumPath = [NSString stringWithFormat:@"thumb/%@", imgIdentifier];
        if (thumbFlag) {
            lastestImagePathStr = thumPath;
        }

        pictureObject = [[TPictureAudioObject alloc]init];
        
        [[TZImageManager manager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
            
            NSData *imageData = UIImagePNGRepresentation(photo); // 或者使用 UIImageJPEGRepresentation
            BOOL originFlag = [imageData writeToFile:imagePath atomically:YES];
            
            [pictureObject setName:imgIdentifier];
            [pictureObject setPath:imgIdentifier];  //  使用image的identifier作为文件名
            [pictureObject setThumbPath:thumPath];
            [pictureObject setType:PICTURE_TYPE];
            [pictureObject setState: USEFUL_STATE_TYPE];
            [pictureObject setAlbumName: self.albumName];
            [pictureObject setAlbumId: self.albumId];
            
            [self addRecordInDB:pictureObject];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateCollectionViewDataArrayWithOnePhoto:pictureObject];
                if (i == assets.count - 1) {
                    if (self.updateAlbumCountBlock) {
                        UIImage *image = [UIImage imageWithData:thumbImageData];
                        self.updateAlbumCountBlock(self.dataArray.count, image);

                    }
                }
            });
            
        }];
        
        

    }
    //  update 源Album表的照片总数
    NSInteger totalPhotoCount = self.dataArray.count + _selectedPhotos.count;
    [self updateAlbumPhotoCount:totalPhotoCount andAlbumId:self.albumId];
    
    [self updateAlbumLastestImagePath:lastestImagePathStr];
    

        dispatch_async(dispatch_get_main_queue(), ^{
        [self.waitingAlert hideView];
        [self showSuccess: self.albumName];
            
        });
}


/// 多选编辑按钮
/// - Parameter button: 多选按钮
- (void)multiplySelectAction:(nullable UIBarButtonItem *)button {
    if (!_isEdit) {
        _isEdit = YES;
        [self.rightItem setTitle:@"取消"];
        [self displayEditBottomView];
        [self.collectionView setAllowsMultipleSelection:YES];
        [self.collectionView reloadData];
        return;
    }
    
    _isEdit = !_isEdit;
    [_selectedEditAssets removeAllObjects];
    [self.rightItem setTitle:@"选择"];
    [self hideEditBottomView];
    [self.collectionView setAllowsMultipleSelection:NO];
    [self.collectionView reloadData];
}

/// 展示底部工具栏
- (void)displayEditBottomView {
    _selectedEditAssets = [NSMutableArray array];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            
            CGFloat bottomSafeArea = 0;
            if (@available(iOS 11.0, *)) {
                bottomSafeArea = self.view.safeAreaInsets.bottom; // 获取 Safe Area 的底部高度
            }
            
            CGRect editBottomRectFrame = self.editBottomView.frame;
            editBottomRectFrame.origin.y = self.screenHeight - EditBottomViewHeight - bottomSafeArea;
            self.editBottomView.frame = editBottomRectFrame;
        } completion:^(BOOL finished) {
            
        }];

}

- (void)hideEditBottomView {
    _isEdit = NO;
    _selectedEditAssets = [NSMutableArray array];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect editBottomRectFrame = self.editBottomView.frame;
        editBottomRectFrame.origin.y = self.screenHeight;
        self.editBottomView.frame = editBottomRectFrame;
        } completion:^(BOOL finished) {
                
        }];
}

/// 移至按钮事件
/// - Parameter sender: 对象
- (void)movePictureToAnotherAlbum:(UIButton *)sender {
    
    self.selectedAlbumController = [[TSelectAlbumViewController alloc]init];
    [self.selectedAlbumController setSelectedCount:_selectedEditAssets.count];
    [self.selectedAlbumController setModalTransitionStyle:UIModalPresentationFullScreen];
    [self.selectedAlbumController setDelegate:self];
    [self presentViewController:self.selectedAlbumController animated:YES completion:^{
            
    }];

}

- (void)deletePictureFromAlbum:(UIButton *)sender {
    
    self.warningAlert = [[SCLAlertView alloc] init];
    __weak id weakself = self;
    [self.warningAlert addButton:@"确定" actionBlock:^{
        [weakself deletePictureFromAlbumConfirm];
        [weakself multiplySelectAction:nil];
    }];
//    [self.warningAlert setShowAnimationType:SCLAlertViewShowAnimationSlideInFromCenter];
    [self.warningAlert showWarning:self.navigationController title:@"即将删除" subTitle:@"您确定要将这些照片或视频从相册中移除?" closeButtonTitle:@"取消" duration:0];
    
}

/// 移除照片,点击确认后
- (void)deletePictureFromAlbumConfirm{
    //  删除相册中的照片
    //  更新相簿的总数
    //  更新相簿的最后一张照片的信息
    //  更新Collectionviewcell
    //  更新相册页面总数显示
    for (TPictureAudioObject *pictureObj in _selectedEditAssets) {
        [self.storage updatePictureState:pictureObj.state == 1 ? 0 : 1  andID:pictureObj.id];
    }
    NSInteger releasePhoto = self.dataArray.count - _selectedEditAssets.count;
    [self.storage updateAlbumPhotoCount:_albumId andCount:releasePhoto];
    
    for (TPictureAudioObject *obj in _selectedEditAssets) {
        if ([self.dataArray containsObject:obj]) {
            [self.dataArray removeObject:obj];
            [self.collectionView reloadData];
        }
    }
    
    NSString *lastThumbImagePath = [(TPictureAudioObject *)self.dataArray.lastObject thumbPath];
    [self.storage updateAlbumLastestImagePath:lastThumbImagePath albumId:_albumId];
    
    if (self.updateAlbumCountBlock) {
        
        if (self.documentsPath.length == 0) {
            self.documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        }
        NSString *thumbPath = [self.documentsPath stringByAppendingPathComponent:[(TPictureAudioObject *)self.dataArray.lastObject thumbPath]];
        
        UIImage *image = [UIImage imageWithContentsOfFile:thumbPath];
        self.updateAlbumCountBlock(self.dataArray.count, image);
        
    }
    
    if (self.updateGarbageBlock) {
        self.updateGarbageBlock(_selectedEditAssets.count);
    }
    
    
}

- (void)showSuccess:(NSString *)title andSubTitle:(NSString *)subTitle andCloseBtnTitle:(NSString *)closeTitle
{

    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [NSBundle mainBundle].resourcePath]];

    [alert showInfo:self title:title subTitle:subTitle closeButtonTitle:closeTitle duration:0.0f];

}

/// 转移照片 - 选择相册,并确定后,的代理方法
/// - Parameter albumId: 目的相册的ID
/// - Parameter albumName: 目的相册的名字
/// - Parameter photoCount: 目的相册添加照片后的总数
- (void)selectedAlbum:(NSInteger)albumId andAlbumName:(nonnull NSString *)albumName andAlbumPhotoCount:(int)photoCount {
    for (TPictureAudioObject *pictureObj in _selectedEditAssets) {
        [pictureObj setAlbumId:albumId];
        [pictureObj setAlbumName:albumName];
        [self.storage updatePictureBelongAlbum:pictureObj andAlbumCount:photoCount];
        //  更新目的相册照片总数
        [self.storage updateAlbumPhotoCount:albumId];
    }
    TPictureAudioObject *lastobj = (TPictureAudioObject *)_selectedEditAssets.lastObject;
    
    if (self.documentsPath.length == 0) {
        self.documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    }
    
    
    UIImage *destiationImage = [UIImage imageWithContentsOfFile: [self.documentsPath stringByAppendingPathComponent:lastobj.thumbPath]];
    //  调用viewcontroller中的block,更新UI,相册中照片的总数
    self.updateDestinationAlbumCountBlock(albumId, photoCount, destiationImage);
    
    //  更新Album表的lastest_image_path值
    [self.storage updateAlbumLastestImagePath:[(TPictureAudioObject *)_selectedEditAssets.lastObject thumbPath] albumId:albumId];
    
    //  更新原相册照片总数
    [self.storage updateAlbumPhotoCount:_albumId andCount:self.dataArray.count - _selectedEditAssets.count];
    
    for (TPictureAudioObject *obj in _selectedEditAssets) {
        if ([self.dataArray containsObject:obj]) {
            [self.dataArray removeObject:obj];
            [self.collectionView reloadData];
        }
    }
    

    if (self.updateAlbumCountBlock) {
        
        NSString *thumbPath = [self.documentsPath stringByAppendingPathComponent:[(TPictureAudioObject *)self.dataArray.lastObject thumbPath]];
        
        UIImage *image = [UIImage imageWithContentsOfFile:thumbPath];
        self.updateAlbumCountBlock(self.dataArray.count, image);
        [self updateAlbumLastestImagePath:[(TPictureAudioObject *)self.dataArray.lastObject thumbPath]];
        
    }
    
    
    [self.rightItem setTitle:@"选择"];
    [self hideEditBottomView];
    [self.collectionView setAllowsMultipleSelection:NO];   
    [self showSuccess: albumName];

}

@end
