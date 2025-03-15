//
//  TPictureDetailViewController.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/16.
//

#import "TPictureDetailViewController.h"
#import "TPictureAudioObject.h"
#import "Masonry.h"
#import "TStorage.h"

#import <SCLAlertView.h>

NSString *kSuccessTitle = @"已生成";//@"Congratulations";
NSString *kErrorTitle = @"Connection error";
NSString *kNoticeTitle = @"Notice";
NSString *kWarningTitle = @"Warning";
NSString *kInfoTitle = @"已完成";
NSString *kSubtitle = @"新的照片已保存到相册中";//@"You've just displayed this awesome Pop Up View";
NSString *kButtonTitle = @"好的";
NSString *kAttributeTitle = @"Attributed string operation successfully completed.";

@interface TPictureDetailViewController () {
    UIImage *_image;
    NSInteger _pageIndex;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIView *topToolbar;
@property (nonatomic, strong) SCLAlertView *warningAlert;

@property (nonatomic, assign) BOOL areBarsHidden;
 
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSArray<TPictureAudioObject *> *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic, strong) NSCache *imageCache;  //  已无使用
@property (nonatomic, assign) NSInteger totalImages;
@property (nonatomic, strong) NSMutableDictionary *visibleImageViews;
@property (nonatomic, strong) NSMutableSet *reusableZoomScrollViews; // 可复用的缩放滚动视图
//@property (nonatomic, strong) NSMutableArray *imageNameArray;
@property (nonatomic, strong) NSArray *imageNameArray;
@property (nonatomic, strong) NSDictionary *imageNameMap; // 用于存储索引和文件名的映射


@property (nonatomic, strong) NSString *documentsPath;

@property (nonatomic, strong) TStorage *storage;
@property (nonatomic, assign) NSInteger albumId;
@property (nonatomic, strong) NSString *albumName;

@end

@implementation TPictureDetailViewController


- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath assetsFetchResults:(NSArray<TPictureAudioObject *> *)assetsFetchResults imageManager:(PHCachingImageManager *)imageManager andAlbumId:(NSInteger)albumId andAlbumName:(nonnull NSString *)albumName{
    
    self = [super init];
    if (self) {
        
        self.storage = [TStorage shareStorage];
        self.currentIndexPath = indexPath;
        self.assetsFetchResults = assetsFetchResults;
        self.imageManager = imageManager;
        self.visibleImageViews = [NSMutableDictionary dictionary];
        
        self.reusableZoomScrollViews = [NSMutableSet set];
        self.totalImages = assetsFetchResults.count;
        self.imageCache = [[NSCache alloc] init];
        self.albumId = albumId;
        self.albumName = albumName;
        
//        self.imageNameArray = [NSMutableArray array];
        // 初始化文件名映射（这里假设文件名是预先生成的随机字符串）
        NSMutableDictionary *map = [NSMutableDictionary dictionary];
        for (NSInteger i = 0; i < self.totalImages; i++) {
            map[@(i)] = self.assetsFetchResults[i].name;
//            [self.imageNameArray addObject:self.assetsFetchResults[i].name];
        }
        self.imageNameMap = [map copy];
        self.imageNameArray = [self orderKey:self.imageNameMap.allKeys];
        self.documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    }
    return self;
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * self.assetsFetchResults.count, self.view.bounds.size.height);
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * self.currentIndexPath.item, 0)];
//    self.scrollView.minimumZoomScale = 1.0;
//    self.scrollView.maximumZoomScale = 6.0; // 最大缩放比例，可以根据需要调整
    [self.view addSubview:self.scrollView];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
//    [self loadImageForPage:0];
//    [self loadImageForPage:1];
    
    // 预加载第500张照片
//     [self loadImageAtIndex:self.currentIndexPath.item];
     

//    [self setupVisibleImagesForOffset:self.scrollView.contentOffset.x];
    self.topToolbar = [[UIView alloc]init];
    [self.topToolbar setBackgroundColor:[UIColor whiteColor]];
    CALayer *topToolbarLayer = self.topToolbar.layer;
    [topToolbarLayer setBorderWidth:1];
    [topToolbarLayer setBorderColor:[UIColor lightGrayColor].CGColor];
//    self.topToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.topToolbar];
    
    [self.topToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.height.equalTo(@88);
    }];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [closeButton addTarget:self action:@selector(closeBrowserAction:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"circle_close"] forState:UIControlStateNormal];
    [self.topToolbar addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topToolbar.mas_leftMargin).offset(10);
        make.bottom.equalTo(self.topToolbar.mas_bottom).offset(-10);
        make.height.equalTo(@30);
        make.width.equalTo(@30);
    }];
    

    // 初始化工具栏
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.translatesAutoresizingMaskIntoConstraints = NO; // 禁用自动调整框架
    
    // 设置工具栏样式（可选）
    // self.toolbar.barStyle = UIBarStyleBlack; // 例如，设置为黑色样式
    
    // 创建工具栏项目（按钮）
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"分享", @"分享") style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped:)];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"编辑", @"编辑") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonTapped:)];
    
    UIBarButtonItem *moveButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"转移", @"转移") style:UIBarButtonItemStylePlain target:self action:@selector(moveButtonTapped:)];
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"删除", @"删除") style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonTapped:)];
    
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc]initWithTitle: NSLocalizedString(@"详情", @"详情") style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonTapped:)];
//    [moreButton setTintColor:[UIColor blackColor]];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithTitle:@"Action" style:UIBarButtonItemStylePlain target:self action:@selector(actionButtonTapped:)];
    
    
    // 设置工具栏项目
    self.toolbar.items = @[flexibleSpace, shareButton, flexibleSpace, editButton, flexibleSpace, deleteButton, flexibleSpace, moreButton, flexibleSpace];
    
    // 将工具栏添加到视图控制器的视图中
    [self.view addSubview:self.toolbar];

    [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
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
    }];
    
    // 添加点击手势识别器
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapGesture];
    
}

- (UIImage *)loadImageAtIndex:(NSInteger)index {
//    NSString *tempPath = self.imageNameArray[index];
    NSLog(@"LoadImageAtIndex: %ld", index);
    NSNumber *tem = [self.imageNameArray objectAtIndex:index];
    [self.imageNameMap objectForKey:tem];
    NSInteger keyInDicIndex = [self.imageNameMap.allKeys indexOfObject:@(index)];

//    self.imageNameMap objec
    NSInteger numberInDic = [self.imageNameMap.allKeys indexOfObject:@(index)];
    NSString *filePath = [self.imageNameMap objectForKey:tem];//[self.imageNameMap.allValues objectAtIndex:numberInDic];
    filePath = [self imagePathForFileName:filePath];
//    NSLog(@"tempPath %@ ==  %@", tempPath, filePath);
    _image = [UIImage imageWithContentsOfFile:filePath];
    return _image; // 这里实际上不返回，只是为了说明加载逻辑
}

- (NSString *)imagePathForFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)setupVisibleImagesForOffset:(CGFloat)offset {
    _pageIndex = (NSInteger)floor((offset / self.scrollView.bounds.size.width));
//    NSLog(@"这是 %d -- %f", _pageIndex, self.view.frame.size.width);
//    (NSInteger)floor((self.scrollView.contentOffset.x / self.scrollView.bounds.size.width));
    // 计算当前可见的页码范围
    NSInteger firstPage = (NSInteger)floor((self.scrollView.contentOffset.x / self.scrollView.bounds.size.width));
    NSInteger lastPage = (NSInteger)floor((offset + self.scrollView.bounds.size.width - 1) / self.scrollView.bounds.size.width);
    
    // 预加载相邻的图片
    firstPage = MAX(firstPage - 1, 0);
    lastPage = MIN(lastPage + 1, self.assetsFetchResults.count - 1);
    
    for (NSNumber *pageNumber in self.visibleImageViews.allKeys) {
        NSInteger page = [pageNumber integerValue];


//        UIImageView *imageView = (UIImageView *) [subScrollView subviews].firstObject;
//        NSInteger imageViewIndex = imageView.tag;
        NSLog(@"_pageIndex:%ld; first:%ld ; last:%ld", _pageIndex, firstPage, lastPage);
        if (page < firstPage || page > lastPage) {
//            UIView *tem = [self.scrollView viewWithTag:(imageViewIndex)];
//            [imageView removeFromSuperview];
            
            UIScrollView *subScrollView = self.visibleImageViews[pageNumber];
            [self.visibleImageViews removeObjectForKey:pageNumber];
//            [self.visibleImageViews removeObject:subScrollView];
            [subScrollView removeFromSuperview];
            [self.reusableZoomScrollViews addObject:subScrollView];
            
            NSLog(@"移除 可视 %d -- 回收站%ld", self.visibleImageViews.count, self.reusableZoomScrollViews.count);
        }
//        if (abs((int)(imageViewIndex - (2000+_pageIndex))) > 2) { // 只保留当前页和前后各一页
//            UIView *tem = [self.scrollView viewWithTag:1000 + (2000-imageViewIndex)];
//            [imageView removeFromSuperview];
//            [self.visibleImageViews removeObjectForKey:@(2000 - imageViewIndex)];
////            [self.visibleImageViews removeObject:subScrollView];
//            [subScrollView removeFromSuperview];
//            [self.reusableZoomScrollViews addObject:subScrollView];
//            
////            NSLog(@"================================================= %ld", imageViewIndex);
//        }
    }
    
    
    // 加载当前可见的图片
    for (NSInteger page = firstPage; page <= lastPage; page++) {
        
//    }
//    // 添加新的可见ImageView
//    for (NSInteger i = -1; i <= 1; i++) {
        
        NSInteger imageViewIndex =  page;
        
//        if (imageViewIndex >= 0 && imageViewIndex < self.totalImages && ![self.visibleImageViews.allKeys containsObject:@(imageViewIndex)]) {
        if (!self.visibleImageViews[@(page)]) {
            
            UIScrollView *zoomScrollView = self.reusableZoomScrollViews.anyObject;
            if (zoomScrollView) {
                [self.reusableZoomScrollViews removeObject:zoomScrollView];
            } else {
                NSLog(@"new Scrollview");
                zoomScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
                zoomScrollView.delegate = self;
                zoomScrollView.minimumZoomScale = 1.0; // 最小缩放比例
                zoomScrollView.maximumZoomScale = 6.0; // 最大缩放比例
                zoomScrollView.showsHorizontalScrollIndicator = NO;
                zoomScrollView.showsVerticalScrollIndicator = NO;
//                zoomScrollView.tag = 1000 + imageViewIndex;
                
                zoomScrollView.zoomScale = 1.0;
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:zoomScrollView.bounds];
                imageView.tag = 1000;
                NSLog(@"图片索引%ld", imageViewIndex);
                [imageView setUserInteractionEnabled:YES];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [zoomScrollView addSubview:imageView];
            }
            
            // 创建缩放滚动视图
            zoomScrollView.frame = CGRectMake((page) * self.scrollView.frame.size.width, 0,
                                              _scrollView.frame.size.width, _scrollView.frame.size.height);
            

            UIImageView *imageView = [zoomScrollView viewWithTag:1000];
            [self loadImageAtIndex:page]; // 加载图片
            imageView.image = _image;
            [zoomScrollView addSubview:imageView];
            //            NSLog(@"tag的值 %d", imageViewIndex);
            self.visibleImageViews[@(page)] = zoomScrollView;
            //            [self.visibleImageViews addObject:zoomScrollView];
            
            [self.scrollView addSubview:zoomScrollView];
        }
//        } else {
////            NSLog(@"done");
//        }
    }
//    NSLog( @"--");
}
 
#pragma mark - UIScrollViewDelegate
 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        [self setupVisibleImagesForOffset:scrollView.contentOffset.x];

    } else {
//        NSLog(@"hi");
    }
}

 
- (NSString *)imagePathForIndex:(NSUInteger)index andImageName:(NSString *)imageName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return [documentsDirectory stringByAppendingPathComponent:imageName];
}


- (void)handleTap:(UITapGestureRecognizer *)gesture {
    // 切换导航栏和工具栏的隐藏状态
    self.areBarsHidden = !self.areBarsHidden;
    
    [self.navigationController setNavigationBarHidden:self.areBarsHidden animated:YES];
    self.toolbar.hidden = self.areBarsHidden;
    self.topToolbar.hidden = self.areBarsHidden;
    
    [self.view setBackgroundColor:self.areBarsHidden ? [UIColor blackColor] : [UIColor whiteColor]];
    // 如果需要，可以在这里调整其他视图的布局
}

/// 点击分享图片
/// - Parameter gesture: 手势
- (void)shareButtonTapped:(UITapGestureRecognizer *)gesture {
    UIActivityIndicatorView *con = [[UIActivityIndicatorView alloc]init];
    // 准备要分享的内容
    NSArray *activityItems = @[];
        // 分享的是普通文本
        activityItems = @[@"hello world"];
        // 分享的是链接
        //activityItems = @[[NSURL URLWithString:@"http://www.baidu.com"]];
        // 分享的是图片
        //activityItems = @[[UIImage imageNamed:@"xxx"]];
        // 分享多个内容
        //activityItems = @[[UIImage imageNamed:@"xxx"],[NSURL URLWithString:@"http://www.baidu.com"],@"hello world"];

    // 创建 UIActivityViewController 实例
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
     
        // 配置 UIActivityViewController（可选）
        // 排除某些活动类型，如 AirDrop
//        activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop];
     
        // 指定分享完成后的回调（iOS 6.0+）
        activityViewController.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            if (completed) {
                NSLog(@"分享成功");
            } else {
                NSLog(@"分享取消或失败：%@", activityError);
            }
        };
     
        // 呈现 UIActivityViewController
        // 对于 iPad，需要使用 UIPopoverController 或 UIPopoverPresentationController
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            // iPad 上的特殊处理
            activityViewController.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popover = activityViewController.popoverPresentationController;
            if (popover) {
                popover.sourceView = self.view; // 指定箭头所指向的视图
                popover.sourceRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 0, 0); // 指定箭头所在的位置
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
        }
     
        [self presentViewController:activityViewController animated:YES completion:nil];

}


/// 点击编辑图片
/// - Parameter gesture: 手势
- (void)editButtonTapped:(UITapGestureRecognizer *)gesture {
//    @try {
        NSString *fileName = self.assetsFetchResults[self.currentIndexPath.item].name;
        
        NSString *filePath = [self imagePathForFileName:fileName];
        UIImage *image = [self.imageCache objectForKey:filePath];
        CGSize imageSize = [image size];
        CLPhotoShopViewController *vc = [[CLPhotoShopViewController alloc] init];
        vc.orgImage = _image;
        vc.delegate = self;
        [self presentViewController:vc animated:true completion:nil];
//    } @catch (NSException *exception) {
//        NSLog(@" ERROR %@", exception.description);
//    } @finally {
//        
//    }
    
    
}

- (void)moveButtonTapped:(UITapGestureRecognizer *)gesture {
    
}

/// 点击删除图片
/// - Parameter gesture: 手势
- (void)deleteButtonTapped:(UITapGestureRecognizer *)gesture {
    self.warningAlert = [[SCLAlertView alloc] init];
    __weak id weakself = self;
    [self.warningAlert addButton:@"确定" actionBlock:^{
        [weakself deletePictureFromAlbumConfirm];
//        [weakself multiplySelectAction:nil];
    }];
//    [self.warningAlert setShowAnimationType:SCLAlertViewShowAnimationSlideInFromCenter];
    [self.warningAlert showWarning:self title:@"即将删除" subTitle:@"您确定要将这些照片或视频从相册中移除?" closeButtonTitle:@"取消" duration:0];

}

/// 点击详情图片
/// - Parameter gesture: 手势
- (void)moreButtonTapped:(UITapGestureRecognizer *)gesture {
    
}

- (void)closeBrowserAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // 计算当前显示的图片索引
    NSInteger currentIndex = (NSInteger)(self.scrollView.contentOffset.x / self.view.frame.size.width);
//    NSLog(@"Current image index: %ld", (long)currentIndex);
    
    if (scrollView != self.scrollView) {
        UIView *tempView = [scrollView viewWithTag:1000];
        return tempView; // 返回当前页的ImageView[4]
    }
    return nil;
    
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollView.scrollEnabled = NO; // 缩放时禁止滚动[8]
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    self.scrollView.scrollEnabled = YES; // 恢复滚动[8]
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)CLPhotoShopViewControllerFinishImage:(UIImage *)image {
//    self.image = image;
    
    CGSize imageSize = [image size];
    // 生成一个 0 到 100 之间的随机整数
    int randomNumber = arc4random_uniform(99999); // 101 是上限，生成的数在 0 到 100 之间
    NSString *fileName = self.assetsFetchResults[self.currentIndexPath.item].name;	
    NSArray *fileNames = [fileName componentsSeparatedByString:@"."];
    if (fileNames.count != 2) {
        return;
    }
    
    fileName = [NSString stringWithFormat:@"%@_%d.%@", fileNames[0], randomNumber, fileNames[1]];
    NSString *imagePath = [self.documentsPath stringByAppendingPathComponent: fileName];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:imagePath atomically:YES];
    
    CGSize thumbSize = CGSizeMake(self.image.size.width, self.image.size.height);
    
    UIGraphicsBeginImageContextWithOptions(thumbSize, NO, 0);
    [image drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
    // 从当前上下文获取图像
    UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString *thumbDirPah = [self.documentsPath stringByAppendingPathComponent: @"thumb"];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *thumbImagePath = [thumbDirPah stringByAppendingPathComponent:fileName];
    
    NSData *thumbImageData = UIImagePNGRepresentation(thumbnailImage);
    BOOL flag2 = [thumbImageData writeToFile:thumbImagePath atomically:YES];
    NSLog(@"");
    
    if (flag2) {
        TPictureAudioObject *pictureObject = [[TPictureAudioObject alloc]init];
        [pictureObject setName:fileName];
        [pictureObject setPath:imagePath];
        [pictureObject setThumbPath:thumbImagePath];
        
        [pictureObject setType: PICTURE_TYPE];
        [pictureObject setState: USEFUL_STATE_TYPE];
        [pictureObject setAlbumName: self.albumName];
        [pictureObject setAlbumId: self.albumId];
        [self addRecordInDB:pictureObject];
    }
    
}

/// 移除照片,点击确认后
- (void)deletePictureFromAlbumConfirm{
    //  删除相册中的照片
    //  更新相簿的总数
    //  更新相簿的最后一张照片的信息
    //  更新Collectionviewcell
    //  更新相册页面总数显示
    NSInteger currentPage = (NSInteger)floor(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width);
    
    NSMutableArray *mutableAssetsResultArray = self.assetsFetchResults.mutableCopy;
    TPictureAudioObject *needToDeleteObj = [mutableAssetsResultArray objectAtIndex:currentPage];
    [mutableAssetsResultArray removeObject:needToDeleteObj];
    self.assetsFetchResults = mutableAssetsResultArray.copy;
    
    [self deleteRecordInDB:needToDeleteObj];
    
    NSLog(@"Delete index %ld", currentPage);
    // 如果没有图片，直接返回
    if (self.imageNameMap.count == 0) {
        return;
    }
    
    NSNumber *currentNumber = self.imageNameArray[currentPage];
    
    NSMutableDictionary *map = [self.imageNameMap mutableCopy];
    [map removeObjectForKey:currentNumber];
    self.imageNameMap = map.copy;
    self.imageNameArray = [self orderKey:self.imageNameMap.allKeys];
    
    // 更新主滚动视图的内容大小
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * self.imageNameMap.count, self.view.bounds.size.height);
    
    // 移除当前显示的缩放滚动视图
    UIScrollView *currentZoomScrollView = self.visibleImageViews[@(currentPage)];
    if (currentZoomScrollView) {
        [currentZoomScrollView removeFromSuperview];
        [self.visibleImageViews removeObjectForKey:@(currentPage)];
        [self.reusableZoomScrollViews addObject:currentZoomScrollView];
    }
    
    [self setupVisibleImagesForOffset:self.scrollView.contentOffset.x];
    
    // 如果删除的是最后一张照片，显示前一张
    if (currentPage >= self.imageNameMap.count) {
        currentPage = self.imageNameMap.count - 1;
        
        NSString *fileName = self.assetsFetchResults.lastObject.name;
        fileName = [@"thumb" stringByAppendingPathComponent:fileName];
//        NSString *filePath = [self imagePathForFileName:fileName];
        UIImage *image = [self.imageCache objectForKey:fileName];
        NSDictionary *changeDictionary = @{ChangeLastestPhotoNotificationKey: @(_albumId), @"LastestPhotoPath": fileName};
//        changeDictionary[ChangeLastestPhotoNotificationKey] = _albumId;
        
        [self updateAlbumLastestImagePath:fileName];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:ChangeLastestPhotoNotification object:changeDictionary];
    }
    
    // 如果删除后没有图片了，返回上一页
    if (self.imageNameMap.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    // 滚动到下一张照片
    [self.scrollView setContentOffset:CGPointMake(self.view.bounds.size.width * currentPage, 0) animated:YES];
    
}

- (void)updateAlbumLastestImagePath:(NSString *)imagePath {
    [self.storage updateAlbumLastestImagePath:imagePath albumId:self.albumId];
    
}

- (NSArray *)orderKey:(NSArray *)oriArray {
    NSArray *descendingArr = [oriArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber*  _Nonnull obj1, NSNumber*  _Nonnull obj2) {
        if ([obj1 compare:obj2] > 0) {
            return YES;
        }
        return NO;
    }];
    return descendingArr;
}


/**
 插入数据库
 */
- (void)addRecordInDB: (TPictureAudioObject *) pictureObject{
    BOOL flag = [self.storage insertPicture:pictureObject];
    [self.storage updateAlbumPhotoCount:self.albumId];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [self showSuccess];
        }];
    });
}

/// 修改对象记录状态为0
/// - Parameter pictureObject: 对象
- (void)deleteRecordInDB:(TPictureAudioObject *)pictureObject {
    [self.storage updatePictureState:USELESS_STATE_TYPE andID:pictureObject.id];
    
    
    NSInteger releasePhoto = self.assetsFetchResults.count;
    [self.storage updateAlbumPhotoCount:_albumId andCount:releasePhoto];
    
//    [self updateAlbumLastestImagePath:lastestImagePathStr];
    NSDictionary *data = @{DeleteToGarbageNotificationCountKey: @1, @"originAlbumCountKey": @(releasePhoto), @"CellId": @(self.albumId)};

    
    [[NSNotificationCenter defaultCenter] postNotificationName:DeleteToGarbageNotification
                                                          object:data];
    
}

- (void)showSuccess
{

    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [NSBundle mainBundle].resourcePath]];

    [alert showInfo:self title:kInfoTitle subTitle:kSubtitle closeButtonTitle:kButtonTitle duration:0.0f];

}


@end
