//
//  TPictureDetailViewController.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/16.
//

#import "TPictureDetailViewController.h"
#import "Masonry.h"

@interface TPictureDetailViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, assign) BOOL areBarsHidden;

@end

@implementation TPictureDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.areBarsHidden = NO;

    // 获取导航控制器的导航条
//        UINavigationBar *navigationBar = self.navigationController.navigationBar;
//        
//        // 设置导航条背景颜色
//        UIColor *backgroundColor = [UIColor redColor]; // 将红色替换为你想要的颜色
//        navigationBar.barTintColor = backgroundColor;
    
    // 设置导航栏为不透明
//        self.navigationController.navigationBar.translucent = NO;
        
        // 可能需要调整视图的布局来适应不透明的导航栏
        // 例如，设置 edgesForExtendedLayout
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 6.0; // 设置最大缩放比例
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = self.scrollView.bounds;
    // 将 UIImageView 的 clipsToBounds 设置为 YES，以裁剪超出边界的部分
        self.imageView.clipsToBounds = YES;
    [self.scrollView addSubview:self.imageView];
    
//    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    self.scrollView.contentSize = self.imageView.frame.size; // 设置 scrollView 的内容大小
    
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
