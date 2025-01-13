//
//  FMDatabaseQueue+SaftyBo.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//

#import "FMDatabaseQueue+SaftyBo.h"
#import "TStorage.h"
#import "GlobalDefine.h"
#import "Sql.h"

#define DB_PATH [NSString stringWithFormat:@"%@/%@.db", ST_DOCUMENT_DIRECTORY, ST_APP_NAME]

@implementation FMDatabaseQueue (SaftyBo)
+ (instancetype)shareInstense {
    
    static FMDatabaseQueue *queue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 根据路径，创建数据库
        queue = [FMDatabaseQueue databaseQueueWithPath:DB_PATH];
        
        [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            @try {
                // 检查当前数据库版本
                FMResultSet *rs = [db executeQuery:@"SELECT version FROM t_schema_migrations WHERE version = ?", @(1)];
                if (![rs next]) {
                    
                    BOOL versionFlag = [db executeUpdate:createVersionSQL];
                    BOOL contactFlag =[db executeUpdate:createContactSQL];
                    BOOL albumFlag =[db executeUpdate:createAlbumSQL];
                    BOOL fakeFlag =[db executeUpdate:createFakeAlbumSQL];
                    BOOL pictureFlag =[db executeUpdate:createPictureSQL];
                    BOOL employerFlag =[db executeUpdate:createEmployerSQL];
//                    // 执行升级操作
//                    BOOL success = [db executeUpdate:@"ALTER TABLE users ADD COLUMN email TEXT"];
//                    if (!success) {
//                        NSLog(@"升级失败");
//                        *rollback = YES;
//                        return;
//                    }
//
                    // 记录升级版本
                    BOOL success = [db executeUpdate:@"INSERT INTO t_schema_migrations (version) VALUES (?)", @(1)];
                    if (!success) {
                        NSLog(@"记录升级版本失败");
                        *rollback = YES;
                        return;
                    }
                    
                }
            }
            @catch (NSException *exception) {
                NSLog(@"发生异常：%@", exception);
                *rollback = YES;
            }
        }];
    });

    return queue;
}
@end
