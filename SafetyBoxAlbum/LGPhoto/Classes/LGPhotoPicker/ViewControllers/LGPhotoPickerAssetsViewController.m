//
//  LGPhotoPickerAssetsViewController.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.


#import <AssetsLibrary/AssetsLibrary.h>
#import "LGPhoto.h"
#import "LGPhotoPickerCollectionView.h"
#import "LGPhotoPickerGroup.h"
#import "LGPhotoPickerCollectionViewCell.h"
#import "LGPhotoPickerFooterCollectionReusableView.h"

#pragma clang diagnostic ignored "-Wprotocol"

static CGFloat CELL_ROW = 4;
static CGFloat CELL_MARGIN = 2;
static CGFloat CELL_LINE_MARGIN = 2;
static CGFloat TOOLBAR_HEIGHT = 44;

static NSString *const _cellIdentifier = @"cell";
static NSString *const _footerIdentifier = @"FooterView";
static NSString *const _identifier = @"toolBarThumbCollectionViewCell";
@interface LGPhotoPickerAssetsViewController () <LGPhotoPickerCollectionViewDelegate,UICollectionViewDataSource,LGPhotoPickerBrowserViewControllerDataSource,LGPhotoPickerBrowserViewControllerDelegate>

// View
// 相片View
@property (nonatomic) LGPhotoPickerCollectionView *collectionView;
// 标记View
@property (nonatomic, weak) UILabel *makeView;
@property (nonatomic) UIButton *sendBtn;
@property (nonatomic) UIButton *previewBtn;
@property (nonatomic) UIButton *allBtn;
@property (nonatomic, weak) UIToolbar *toolBar;
@property (nonatomic, assign) NSUInteger privateTempMaxCount;
@property (nonatomic) NSMutableArray *assets;
@property (nonatomic) NSMutableArray<__kindof LGPhotoAssets*> *selectAssets;
@property (strong, nonatomic) NSMutableArray *takePhotoImages;
// 1 - 相册浏览器的数据源是 selectAssets， 0 - 相册浏览器的数据源是 assets
@property (nonatomic, assign) BOOL isPreview;
// 是否发送原图
@property (nonatomic, assign) BOOL isOriginal;

@end

@implementation LGPhotoPickerAssetsViewController

#pragma mark - dealloc

- (void)dealloc {
    
}

#pragma mark - init

- (instancetype)initWithShowType:(LGShowImageType)showType {
    self = [super init];
    if (self) {
        self.showType = showType;
    }
    return self;
}

#pragma mark - circle life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.bounds = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor clearColor];
    // 获取相册
    [self setupAssets];
    
    [self addNavBarCancelButton];
    // 初始化底部toolBar
    [self setuptoolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.collectionView.selectAssets = [NSMutableArray arrayWithArray:self.selectAssets];
    self.collectionView.maxCount = self.maxCount;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 赋值给上一个控制器,以便记录上次选择的照片
    if (self.selectedAssetsBlock) {
        self.selectedAssetsBlock(self.selectAssets);
    }
}

#pragma mark - getter

- (NSMutableArray *)selectAssets {
    if (!_selectAssets) {
        _selectAssets = [NSMutableArray array];
    }
    return _selectAssets;
}

- (NSMutableArray *)takePhotoImages {
    if (!_takePhotoImages) {
        _takePhotoImages = [NSMutableArray array];
    }
    return _takePhotoImages;
}

- (UIButton *)allBtn {
    if (!_allBtn) {
        UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [centerBtn setTitleColor:[UIColor colorWithRed:0x45 green:0x9a blue:0x00 alpha:1] forState:UIControlStateNormal];
        [centerBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        centerBtn.enabled = YES;
        centerBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        centerBtn.frame = CGRectMake(0, 0, 60, 45);
        NSString *title = [NSString stringWithFormat:@"All",0];
        [centerBtn setTitle:title forState:UIControlStateNormal];
        [centerBtn addTarget:self action:@selector(sendBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        self.allBtn = centerBtn;
    }
    return _allBtn;
}

#pragma mark Get View
- (UIButton *)sendBtn {
    if (!_sendBtn) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitleColor:[UIColor colorWithRed:0x45 green:0x9a blue:0x00 alpha:1] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        rightBtn.enabled = YES;
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        rightBtn.frame = CGRectMake(0, 0, 60, 45);
        NSString *title = [NSString stringWithFormat:@"选中(%d)",0];
        [rightBtn setTitle:title forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(sendBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        self.sendBtn = rightBtn;
    }
    return _sendBtn;
}

- (UIButton *)previewBtn {
    if (!_previewBtn) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        leftBtn.enabled = YES;
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        leftBtn.frame = CGRectMake(0, 0, 45, 45);
        [leftBtn setTitle:@"预览" forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(previewBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        self.previewBtn = leftBtn;
    }
    return _previewBtn;
}

- (void)previewBtnTouched {
    [self setupPhotoBrowserInCasePreview:YES CurrentIndexPath:0];
}

/**
 *  跳转照片浏览器
 *
 *  @param preview YES - 从‘预览’按钮进去，浏览器显示的时被选中的照片
 *                  NO - 点击cell进去，浏览器显示所有照片
 *  @param CurrentIndexPath 进入浏览器后展示图片的位置
 */
- (void) setupPhotoBrowserInCasePreview:(BOOL)preview
                       CurrentIndexPath:(NSIndexPath *)indexPath {
    
    self.isPreview = preview;
    // 图片游览器
    LGPhotoPickerBrowserViewController *pickerBrowser = [[LGPhotoPickerBrowserViewController alloc] init];
    pickerBrowser.showType = self.showType;
    // 数据源/delegate
    pickerBrowser.delegate = self;
    pickerBrowser.dataSource = self;
    pickerBrowser.maxCount = self.maxCount;
	pickerBrowser.nightMode = self.nightMode;
    pickerBrowser.isOriginal = self.isOriginal;
    pickerBrowser.selectedAssets = [self.selectAssets mutableCopy];
    // 数据源可以不传，传photos数组 photos<里面是ZLPhotoPickerBrowserPhoto>
//    pickerBrowser.photos = self.selectAssets;
    // 是否可以删除照片
    pickerBrowser.editing = NO;
    // 当前选中的值
    pickerBrowser.currentIndexPath = indexPath;    // 展示控制器
//    [pickerBrowser showPickerVc:self];
    [self.navigationController presentViewController:pickerBrowser animated:YES completion:nil];
    
}

- (void)setSelectPickerAssets:(NSArray *)selectPickerAssets {
    NSSet *set = [NSSet setWithArray:selectPickerAssets];
    _selectPickerAssets = [set allObjects];
    
    if (!self.assets) {
        self.assets = [NSMutableArray arrayWithArray:selectPickerAssets];
    }else{
        [self.assets addObjectsFromArray:selectPickerAssets];
    }
    
    self.selectAssets = [selectPickerAssets mutableCopy];
    self.collectionView.lastDataArray = nil;
    self.collectionView.isRecoderSelectPicker = YES;
    self.collectionView.selectAssets = self.selectAssets;
    NSInteger count = self.selectAssets.count;
    self.makeView.hidden = !count;
    self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
    self.sendBtn.enabled = (count > 0);
    self.previewBtn.enabled = (count > 0);
    
    [self updateToolbar];
}

- (void)setTopShowPhotoPicker:(BOOL)topShowPhotoPicker {
    _topShowPhotoPicker = topShowPhotoPicker;

    if (self.topShowPhotoPicker == YES) {
        NSMutableArray *reSortArray= [[NSMutableArray alloc] init];
        for (id obj in [self.collectionView.dataArray reverseObjectEnumerator]) {
            [reSortArray addObject:obj];
        }
        
        LGPhotoAssets *lgAsset = [[LGPhotoAssets alloc] init];
        [reSortArray insertObject:lgAsset atIndex:0];
        
        self.collectionView.status = LGPickerCollectionViewShowOrderStatusTimeAsc;
        self.collectionView.topShowPhotoPicker = topShowPhotoPicker;
        self.collectionView.dataArray = reSortArray;
        [self.collectionView reloadData];
    }
}

#pragma mark collectionView
- (LGPhotoPickerCollectionView *)collectionView {
    if (!_collectionView) {
        
        CGFloat cellW = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1) / CELL_ROW;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellW, cellW);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = CELL_LINE_MARGIN;
        layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, TOOLBAR_HEIGHT * 2);
        
        LGPhotoPickerCollectionView *collectionView = [[LGPhotoPickerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        // 时间置顶
        collectionView.status = LGPickerCollectionViewShowOrderStatusTimeDesc;
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [collectionView registerClass:[LGPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        // 底部的View
        [collectionView registerClass:[LGPhotoPickerFooterCollectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];
        
        collectionView.contentInset = UIEdgeInsetsMake(5, 0,TOOLBAR_HEIGHT, 0);
        collectionView.collectionViewDelegate = self;
        [self.view insertSubview:_collectionView = collectionView belowSubview:self.toolBar];
		collectionView.frame = self.view.bounds;
    }
    return _collectionView;
}

#pragma mark - 创建右边取消按钮

- (void)addNavBarCancelButton {
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																							target:self
																							action:@selector(cancelBtnTouched)];
	self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
}

#pragma mark 初始化所有的组

- (void) setupAssets {
    if (!self.assets) {
        self.assets = [NSMutableArray array];
    }
    
    __block NSMutableArray *assetsM = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LGPhotoPickerDatas defaultPicker] getGroupPhotosWithGroup:self.assetsGroup finished:^(NSArray *assets) {
            
            [assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
                LGPhotoAssets *lgAsset = [[LGPhotoAssets alloc] init];
                lgAsset.asset = asset;
                [assetsM addObject:lgAsset];
            }];
            weakSelf.collectionView.dataArray = assetsM;
            [self.assets setArray:assetsM];
        }];
    });
}

#pragma mark -初始化底部toolBar

- (void) setuptoolBar {
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    [self.view addSubview:toolBar];
    self.toolBar = toolBar;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(toolBar);
    NSString *widthVfl =  @"H:|-0-[toolBar]-0-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    if (@available(iOS 11.0, *)) {
        [toolBar.lastBaselineAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    } else {
        NSString *heightVfl = @"V:[toolBar(44)]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    }
    // 左视图 中间距 右视图
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.previewBtn];
    UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.sendBtn];
    
    toolBar.items = @[leftItem,fiexItem,rightItem];

}

#pragma mark - setter

- (void)setMaxCount:(NSInteger)maxCount {
    _maxCount = maxCount;
    
    if (!_privateTempMaxCount) {
        _privateTempMaxCount = maxCount;
    }

    if (self.selectAssets.count == maxCount) {
        maxCount = 0;
    }else if (self.selectPickerAssets.count - self.selectAssets.count > 0) {
        maxCount = _privateTempMaxCount;
    }
    
    self.collectionView.maxCount = maxCount;
}

- (void)setNightMode:(BOOL)nightMode {
	_nightMode = nightMode;
	if (nightMode == 1) {
		self.view.backgroundColor = NIGHTMODE_COLOR;
	} else {
		self.view.backgroundColor = DAYMODE_COLOR;
	}
}

- (void)setAssetsGroup:(LGPhotoPickerGroup *)assetsGroup {
    if (!assetsGroup.groupName.length) return ;
    
    _assetsGroup = assetsGroup;
    
    self.title = assetsGroup.groupName;
    
    // 获取Assets
//    [self setupAssets];
}

#pragma mark - LGPhotoPickerCollectionViewDelegate

//cell被点击会调用
- (void) pickerCollectionCellTouchedIndexPath:(NSIndexPath *)indexPath {
    [self setupPhotoBrowserInCasePreview:NO CurrentIndexPath:indexPath];
}

//cell的右上角选择框被点击会调用
- (void) pickerCollectionViewDidSelected:(LGPhotoPickerCollectionView *) pickerCollectionView deleteAsset:(LGPhotoAssets *)deleteAssets {

    if (self.selectPickerAssets.count == 0){
        self.selectAssets = [NSMutableArray arrayWithArray:pickerCollectionView.selectAssets];
    } else if (deleteAssets == nil) {
        [self.selectAssets addObject:[pickerCollectionView.selectAssets lastObject]];
    } else if(deleteAssets) { //取消所选的照片
        //根据url删除对象
        NSArray *arr = [self.selectAssets copy];
        for (LGPhotoAssets *selectAsset in arr) {
            if ([selectAsset.assetURL isEqual:deleteAssets.assetURL]) {
                [self.selectAssets removeObject:selectAsset];
            }
        }
    }

    [self updateToolbar];
}

- (void)updateToolbar {
    NSInteger count = self.selectAssets.count;
    self.sendBtn.enabled = (count > 0);
    self.previewBtn.enabled = (count > 0);
    NSString *title = [NSString stringWithFormat:@"选中(%ld)",(long)count];
    [self.sendBtn setTitle:title forState:UIControlStateNormal];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectAssets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    
    if (self.selectAssets.count > indexPath.item) {
        UIImageView *imageView = [[cell.contentView subviews] lastObject];
        // 判断真实类型
        if (![imageView isKindOfClass:[UIImageView class]]) {
            imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = YES;
            [cell.contentView addSubview:imageView];
        }
        imageView.tag = indexPath.item;
        if ([self.selectAssets[indexPath.item] isKindOfClass:[LGPhotoAssets class]]) {
            imageView.image = [self.selectAssets[indexPath.item] thumbImage];
        }else if ([self.selectAssets[indexPath.item] isKindOfClass:[UIImage class]]){
            imageView.image = (UIImage *)self.selectAssets[indexPath.item];
        }
    }

    return cell;
}

#pragma mark - LGPhotoPickerBrowserViewControllerDataSource

- (NSInteger)numberOfSectionInPhotosInPickerBrowser:(LGPhotoPickerBrowserViewController *)pickerBrowser {
    return 1;
}

- (NSInteger)photoBrowser:(LGPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section {
    if (self.isPreview) {
        return self.selectAssets.count;
    } else {
        return self.assets.count;
    }
}

- (LGPhotoPickerBrowserPhoto *)photoBrowser:(LGPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath {
    
    LGPhotoAssets *imageObj = [[LGPhotoAssets alloc] init];
    if (self.isPreview && self.selectAssets.count) {
        imageObj = [self.selectAssets objectAtIndex:indexPath.row];
    } else if (!self.isPreview && self.assets.count){
        imageObj = [self.assets objectAtIndex:indexPath.row];
    }
    // 包装下imageObj 成 LGPhotoPickerBrowserPhoto 传给数据源
    LGPhotoPickerBrowserPhoto *photo = [LGPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    
    LGPhotoPickerCollectionViewCell *cell = (LGPhotoPickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    photo.thumbImage = cell.cellImage;
    
    return photo;
}

#pragma mark - LGPhotoPickerBrowserViewControllerDelegate

- (void)photoBrowserWillExit:(LGPhotoPickerBrowserViewController *)pickerBrowser {
    self.selectAssets = [NSMutableArray arrayWithArray:pickerBrowser.selectedAssets];
    self.collectionView.lastDataArray = nil;
    self.collectionView.isRecoderSelectPicker = YES;
    self.collectionView.selectAssets = self.selectAssets;
    NSInteger count = self.selectAssets.count;
    self.makeView.hidden = !count;
    self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
    self.sendBtn.enabled = (count > 0);
    self.previewBtn.enabled = (count > 0);
    self.isOriginal = pickerBrowser.isOriginal;
    [self updateToolbar];
}

- (void)photoBrowserSendBtnTouched:(LGPhotoPickerBrowserViewController *)pickerBrowser isOriginal:(BOOL)isOriginal {
    self.isOriginal = isOriginal;
    self.selectAssets = pickerBrowser.selectedAssets;
    [self sendBtnTouched];
}

#pragma mark -开启异步通知

- (void) cancelBtnTouched {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendBtnTouched {
	[[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_DONE object:nil userInfo:@{@"selectAssets":self.selectAssets,@"isOriginal":@(self.isOriginal)}];
	NSLog(@"%@",@(self.isOriginal));
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
