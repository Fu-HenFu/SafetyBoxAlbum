//
//  TPictureDetailViewController.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/16.
//

#import "TPictureDetailViewController.h"
#import "TPictureAudioObject.h"
#import "Masonry.h"

@interface TPictureDetailViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, assign) BOOL areBarsHidden;
 
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSArray<TPictureAudioObject *> *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation TPictureDetailViewController


- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath assetsFetchResults:(NSArray<TPictureAudioObject *> *)assetsFetchResults imageManager:(PHCachingImageManager *)imageManager {
    self = [super init];
    if (self) {
        self.currentIndexPath = indexPath;
        self.assetsFetchResults = assetsFetchResults;
        self.imageManager = imageManager;
        
        self.imageCache = [[NSCache alloc] init];
    }
    return self;
}
 
- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    [self loadImageForPage:self.currentIndexPath.item];
    if (self.currentIndexPath.item == self.assetsFetchResults.count - 1) {
        [self loadImageForPage:self.currentIndexPath.item - 1];
    } else {
        [self loadImageForPage:self.currentIndexPath.item + 1];
    }

    /**
    for (NSInteger i = 0; i < self.assetsFetchResults.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        // 获取 Documents 目录路径
            
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.assetsFetchResults[i].name];
        
        // 检查文件是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            // 读取图片数据
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            if (imageData) {
                // 返回 UIImage 对象
                imageView.image = [UIImage imageWithData:imageData];
            }
        }
            // 构建图片文件路径
//            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.assetsFetchResults[i].path];
            
            
//        PHAsset *asset = [PHAsset fetchAssetsWithALAssetURLs:@[self.assetsFetchResults[i].assetURL] options:nil].firstObject;
////        PHAsset *asset = self.assetsFetchResults[i];
//        [self.imageManager requestImageForAsset:asset
//                                     targetSize:CGSizeMake(self.view.bounds.size.width * [UIScreen mainScreen].scale, self.view.bounds.size.height * [UIScreen mainScreen].scale)
//                                    contentMode:PHImageContentModeAspectFit
//                                        options:nil
//                                  resultHandler:^(UIImage *result, NSDictionary *info) {
//            imageView.image = result;
//        }];
        [scrollView addSubview:imageView];
    }
   
    scrollView.contentOffset = CGPointMake(self.currentIndexPath.item * self.view.bounds.size.width, 0);
     */
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
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

#pragma mark - UIScrollViewDelegate
 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // 加载当前页和相邻页的图像
    [self loadImageForPage:currentPage];
    [self loadImageForPage:currentPage + 1];
    [self loadImageForPage:currentPage - 1];
    
    // 这里可以添加逻辑来移除远离当前页的图像视图，以节省内存
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    // 切换导航栏和工具栏的隐藏状态
    self.areBarsHidden = !self.areBarsHidden;
    
    [self.navigationController setNavigationBarHidden:self.areBarsHidden animated:YES];
    self.toolbar.hidden = self.areBarsHidden;
    
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
    
}

- (void)moveButtonTapped:(UITapGestureRecognizer *)gesture {
    
}

- (void)deleteButtonTapped:(UITapGestureRecognizer *)gesture {
    
}

- (void)moreButtonTapped:(UITapGestureRecognizer *)gesture {
    
}

@end
