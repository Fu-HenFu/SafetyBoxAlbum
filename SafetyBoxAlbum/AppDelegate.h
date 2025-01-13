//
//  AppDelegate.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

