//
//  TGarbageViewController.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/2/24.
//

#import "TGarbageViewController.h"

#import "TPictureAudioObject.h"
#import "TStorage.h"
#import "GlobalDefine.h"
#import "Masonry/Masonry.h"
#import "TImageCollectionViewCell.h"
#import "TPictureDetailViewController.h"
#import "TGarbageMultiSelecteView.h"

#define EditBottomViewHeight 80

@interface TGarbageViewController () {
    
    BOOL _isEdit;
    NSMutableArray *_selectedEditAssets;    //  选择照片时,选中的照片对象
}
@property (strong, nonatomic) NSMutableArray<TPictureAudioObject *> *dataArray;

@property (nonatomic, assign) NSInteger albumId;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) UIBarButtonItem *rightItem;
@property (nonatomic, strong) TStorage *storage;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (assign, nonatomic) CGFloat screenWidth;
@property (assign, nonatomic) CGFloat screenHeight;

@property (nonatomic, strong) TGarbageMultiSelecteView *editBottomView;
@property (nonatomic, strong) NSString *documentsPath;
@end

@implementation TGarbageViewController

- (instancetype)initWithAlbumId:(NSInteger)albumId andAlbumName:(NSString *)albumName
{
    self = [super init];
    if (self) {
        self.dataArray = [NSMutableArray array];
        self.rightItem = [[UIBarButtonItem alloc]initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(multiplySelectAction:)];
        [self.navigationItem setRightBarButtonItem:self.rightItem];
        self.storage = [TStorage shareStorage];
        
        _isEdit = NO;
        self.albumId = albumId;
        self.albumName = albumName;
        [self refetchDataFromDatabase];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    self.editBottomView = [[TGarbageMultiSelecteView alloc]initWithFrame:CGRectMake(0, 0, _screenWidth, 0)];
    [self.view addSubview:self.editBottomView];
    [self.editBottomView setBackgroundColor:[UIColor colorWithWhite:244/255.0 alpha:1]];
    [self.editBottomView.restoreButton addTarget:self action:@selector(restorePictureToAlbum:) forControlEvents:UIControlEventTouchUpInside];
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

/**
 查询数据库,获取照片
 */
- (void)refetchDataFromDatabase {
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[self.storage queryGarbagePicture:self.albumId andFakeType:1]];
    
    [self.collectionView reloadData];
    
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


/// 恢复按钮事件
/// - Parameter sender: 对象
- (void)restorePictureToAlbum:(UIButton *)sender {
    //  展示等待提示框
    //  恢复相册中的照片的状态
    //  更新相簿的总数
    //  更新相簿的最后一张照片的信息
    //  更新相册页面总数显示
    //  展示成功提示框
    //  更新回收站页面
    for (TPictureAudioObject *obj in _selectedEditAssets) {
        [obj setState:USEFUL_STATE_TYPE];
        [self.storage updatePictureState:USEFUL_STATE_TYPE andID:obj.id];
        [self.storage updateAlbumPhotoCount:obj.albumId];
        [self.storage updateAlbumLastestImagePath:obj.thumbPath albumId:obj.albumId];
        
        
        if (self.updateAlbumCountBlock) {
            if (self.documentsPath.length == 0) {
                self.documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            }
            
            
            [self.dataArray removeObject:obj];
            NSString *thumbPath = [self.documentsPath stringByAppendingPathComponent:[(TPictureAudioObject *)obj thumbPath]];
            UIImage *image = [UIImage imageWithContentsOfFile:thumbPath];
            self.updateAlbumCountBlock(self.dataArray.count, image);
            
            self.updateDestinationAlbumCountBlock(obj.albumId, 0, image);
        }
    }
    
    
    
}

/// 彻底删除按钮事件
/// - Parameter sender: 对象
- (void)deletePictureFromAlbum:(UIButton *)sender {
    
}

@end
