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

#define LASTESTVERSION 2

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
                FMResultSet *rs = [db executeQuery:@"SELECT version FROM t_schema_migrations; "];
                if (![rs next]) {
                    BOOL success = [queue initDatabase:db];
                    if (!success) {
                        
                        NSLog(@"记录升级版本失败");
                        *rollback = YES;
                        return;
                    }
                } else {
                    NSInteger currentVersion = [rs intForColumn:@"version"];
                    BOOL success = [queue updateDatabase:db databaseVersion:currentVersion];
                    if (!success) {
                        *rollback = YES;
                        return;
                    }
                }
            }
            @catch (NSException *exception) {
                NSLog(@"发生异常：%@", exception);
                *rollback = YES;
            }
            @finally {
                // code that will always be executed. Typically for cleanup.
//                [db close];
            }
        }];
    });

    return queue;
}


/// 初始化数据库
/// - Parameter db: FMDatabase
- (BOOL)initDatabase:(FMDatabase *)db {
    
    BOOL versionFlag = [db executeUpdate:createVersionSQL];
    BOOL contactFlag =[db executeUpdate:createContactSQL];
    BOOL albumFlag =[db executeUpdate:createAlbumSQL];
    BOOL fakeFlag =[db executeUpdate:createFakeAlbumSQL];
    BOOL pictureFlag =[db executeUpdate:createPictureSQL];
    BOOL employerFlag =[db executeUpdate:createEmployerSQL];
    [db executeUpdate:@"INSERT INTO t_album (name, state, type) VALUES ('主相册', 1, 1)"];
    [db executeUpdate:@"INSERT INTO t_album (name, state, type) VALUES ('回收站', 1, 2)"];
    
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
        return NO;
    }
    return YES;
}

/// 更新数据库
/// - Parameter db: FMDatabase 实例
- (BOOL)updateDatabase:(FMDatabase *)db databaseVersion:(NSInteger)currentVersion {
    BOOL success = YES;
    NSInteger lastestVersion = LASTESTVERSION;
    if (currentVersion < lastestVersion) {
        currentVersion++;
        
        success = [self performUpgradeStepForVersion:currentVersion database:db];
    }
    
    return success;
}

- (BOOL)performUpgradeStepForVersion:(NSInteger)version database:(FMDatabase *)db {
    BOOL success = YES;
    switch (version) {
        case 999:
            success = [db executeUpdate:@"ALTER TABLE t_album ADD COLUMN update_time INTEGER DEFAULT 0;"];
            break;
            
        default:
            break;
    }

    
    // 更新数据库版本
    // 记录升级版本
    success = [db executeUpdate:@"UPDATE t_schema_migrations SET version = ? WHERE id = ?", @2, @1];
    return success;
    
}
@end
