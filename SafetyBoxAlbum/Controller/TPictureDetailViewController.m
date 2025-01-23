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

NSString *kSuccessTitle = @"已生成";//@"Congratulations";
NSString *kErrorTitle = @"Connection error";
NSString *kNoticeTitle = @"Notice";
NSString *kWarningTitle = @"Warning";
NSString *kInfoTitle = @"已完成";
NSString *kSubtitle = @"新的照片已保存到相册中";//@"You've just displayed this awesome Pop Up View";
NSString *kButtonTitle = @"好的";
NSString *kAttributeTitle = @"Attributed string operation successfully completed.";

@interface TPictureDetailViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIView *topToolbar;

@property (nonatomic, assign) BOOL areBarsHidden;
 
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSArray<TPictureAudioObject *> *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, assign) NSInteger totalImages;
@property (nonatomic, strong) NSMutableSet *visibleImageViews;
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
        self.visibleImageViews = [NSMutableSet set];
        self.totalImages = assetsFetchResults.count;
        self.imageCache = [[NSCache alloc] init];
        self.albumId = albumId;
        self.albumName = albumName;
        
        // 初始化文件名映射（这里假设文件名是预先生成的随机字符串）
        NSMutableDictionary *map = [NSMutableDictionary dictionary];
        for (NSInteger i = 0; i < self.totalImages; i++) {
            map[@(i)] = self.assetsFetchResults[i].name;
        }
        self.imageNameMap = [map copy];
        
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
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 6.0; // 最大缩放比例，可以根据需要调整
    [self.view addSubview:self.scrollView];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    
//    [self loadImageForPage:0];
//    [self loadImageForPage:1];
    
    // 预加载第500张照片
     [self loadImageAtIndex:self.currentIndexPath.item];
     
     // 初始设置可见范围内的图片
    self.scrollView.contentOffset = CGPointMake(self.currentIndexPath.item * self.view.bounds.size.width, 0);

    [self setupVisibleImagesForOffset:self.scrollView.contentOffset.x];
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
        make.top.equalTo(self.topToolbar.mas_topMargin).offset(-20);
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
    
    NSString *fileName = self.imageNameMap[@(index)];
    NSString *filePath = [self imagePathForFileName:fileName];
    UIImage *image = [self.imageCache objectForKey:filePath];
    
    if (!image) {
        image = [UIImage imageWithContentsOfFile:filePath];
        if (image) {
            [self.imageCache setObject:image forKey:filePath];
        }
    }
    
    return image; // 这里实际上不返回，只是为了说明加载逻辑
}

- (NSString *)imagePathForFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)setupVisibleImagesForOffset:(CGFloat)offset {
    NSInteger pageIndex = (NSInteger)(offset / self.view.bounds.size.width);
    
    // 移除不再可见的ImageView
    for (UIImageView *imageView in [self.visibleImageViews copy]) {
        NSInteger imageViewIndex = imageView.tag;
        if (abs((int)(imageViewIndex - pageIndex)) > 1) { // 只保留当前页和前后各一页
            [imageView removeFromSuperview];
            [self.visibleImageViews removeObject:imageView];
        }
    }
    
    
    // 添加新的可见ImageView
    for (NSInteger i = -1; i <= 1; i++) {
        NSInteger imageViewIndex = pageIndex + i;
        if (imageViewIndex >= 0 && imageViewIndex < self.totalImages && ![self.visibleImageViews containsObject:@(imageViewIndex)]) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewIndex * self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            imageView.tag = imageViewIndex;
            [imageView setContentMode:UIViewContentModeScaleAspectFit];
            UIImage *image = [self loadImageAtIndex:imageViewIndex]; // 加载图片
            imageView.image = image;
            [self.scrollView addSubview:imageView];
            [self.visibleImageViews addObject:imageView];
            
//            if (i == 0) {
//                
//                self.showingImageView = imageView;
//            }
        }
    }
}
 
#pragma mark - UIScrollViewDelegate
 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setupVisibleImagesForOffset:scrollView.contentOffset.x];
}

- (void)loadImageForPage:(NSInteger)page {
    if (page < 0 || page >= self.assetsFetchResults.count) return;
    
    CGRect frame = CGRectMake(page * self.view.bounds.size.width, 0, 
                              self.view.bounds.size.width, self.view.bounds.size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *imagePath = [self imagePathForIndex:page andImageName:self.assetsFetchResults[page].name];
    UIImage *cachedImage = [self.imageCache objectForKey:imagePath];
    
    if (cachedImage) {
        imageView.image = cachedImage;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            if (image) {
                [self.imageCache setObject:image forKey:imagePath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = image;
                });
            }
        });
    }
    
    [self.scrollView addSubview:imageView];
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

- (void)editButtonTapped:(UITapGestureRecognizer *)gesture {
    NSString *fileName = self.assetsFetchResults[self.currentIndexPath.item].name;
    
    NSString *filePath = [self imagePathForFileName:fileName];
    UIImage *image = [self.imageCache objectForKey:filePath];

    CLPhotoShopViewController *vc = [[CLPhotoShopViewController alloc] init];
    vc.orgImage = image;
    vc.delegate = self;
    [self presentViewController:vc animated:true completion:nil];
    
}

- (void)moveButtonTapped:(UITapGestureRecognizer *)gesture {
    
}

- (void)deleteButtonTapped:(UITapGestureRecognizer *)gesture {
    
}

- (void)moreButtonTapped:(UITapGestureRecognizer *)gesture {
    
}

- (void)closeBrowserAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // 计算当前显示的图片索引
    NSInteger currentIndex = (NSInteger)(scrollView.contentOffset.x / self.view.frame.size.width);
    NSLog(@"Current image index: %ld", (long)currentIndex);
    
    return nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)CLPhotoShopViewControllerFinishImage:(UIImage *)image {
    self.image = image;
    
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
    
    CGSize thumbSize = CGSizeMake(100, 100);
    
    UIGraphicsBeginImageContextWithOptions(thumbSize, NO, 0);
    [self.image drawInRect:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
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

- (void)showSuccess
{

    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.soundURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/right_answer.mp3", [NSBundle mainBundle].resourcePath]];

    [alert showInfo:self title:kInfoTitle subTitle:kSubtitle closeButtonTitle:kButtonTitle duration:0.0f];

}


@end
