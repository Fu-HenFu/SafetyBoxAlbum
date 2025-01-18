//
//  AppDelegate.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//

#import "AppDelegate.h"
#import "FMDatabaseQueue+SaftyBo.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    FMDatabaseQueue * db = [FMDatabaseQueue shareInstense];
    [db close];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 创建并设置根视图控制器（这里以ViewController为例）
    ViewController *rootViewController = [[ViewController alloc] init];
    UINavigationController* navController = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    
//    self.window.backgroundColor = UIColor.whiteColor;
    self.window.rootViewController = navController;
    
    // 显示窗口
    [self.window makeKeyAndVisible];
    
    return YES;
}



@end
