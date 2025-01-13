//
//  TStorage.m
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//

#import "TStorage.h"
#import "FMDatabaseQueue+SaftyBo.h"
#import "Sql.h"

#define ROWID @"id"
#define NAME @"name"
#define STATE @"state"


static TStorage* _storage;
static FMDatabaseQueue *_queue;

@interface TStorage ()
//@property (strong, nonatomic) FMDatabaseQueue *db;
@end
@implementation TStorage

+ (instancetype)shareStorage {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_storage == nil) {
            _storage = [[TStorage alloc]init];
            _queue = [FMDatabaseQueue shareInstense];
        }
        
    });
    
    return _storage;
}

- (void)close {
    _storage == nil;
}

/// 新建相薄
- (void)insertAlbum:(NSString *)albumName {
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
//        NSString * sql = [NSString stringWithFormat:InsertAlbumSQL, tableName];
        [db executeUpdate:InsertAlbumSQL, albumName];
    }];
    
}

/// 新建fake相薄QueryLastestAlbumSQL
- (void)insertFakeAlbum:(NSString *)albumName {
    
}

- (TAlbumObject *)getLastestAlbumResultSet {
    
    NSMutableArray* rooms=[NSMutableArray array];
    [_queue inDatabase:^(FMDatabase *db) {
        FMResultSet* rs=[db executeQuery:QueryLastestAlbumSQL];
        while ([rs next]) {
            [rooms addObject:[self getAlbumByRestultSet:rs]];
        }
        [rs close];
    }];

    return rooms.firstObject;
}

- (TAlbumObject *)getAlbumByRestultSet:(FMResultSet *)rs {
    
    TAlbumObject *albumObj = [[TAlbumObject alloc]init];
    albumObj.id = [rs intForColumn:ROWID];
    albumObj.name = [rs stringForColumn:NAME];
    albumObj.state = [rs intForColumn:STATE];
    return albumObj;
    
}
@end

