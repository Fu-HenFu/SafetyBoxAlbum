//
//  Utils.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/2/9.
//

#import "Utils.h"
#import <UIKit/UIKit.h>

// 函数实现
NSString *generateUniqueString(void) {
    // 获取当前时间戳
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    
    // 生成一个随机UUID
    NSUUID *uuid = [NSUUID UUID];
    
    // 获取设备的唯一标识符（可选，需要导入UIKit）
    NSString *deviceIdentifier = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    
    // 组合这些元素来生成一个唯一的字符串
    NSString *uniqueString = [NSString stringWithFormat:@"%f-%@-%@", timestamp, uuid.UUIDString, deviceIdentifier];
    
    // 如果需要更长的字符串，可以使用随机字符填充
    NSMutableString *longUniqueString = [uniqueString mutableCopy];
//    for (NSInteger i = 0; i < 50; i++) { // 添加50个随机字符
//        unichar randomChar = arc4random_uniform(94) + 33; // 生成33到126之间的ASCII字符
//        [longUniqueString appendFormat:@"%C", randomChar];
//    }
    
    return [longUniqueString copy];
}
