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
#define PHOTO_COUNT @"photo_count"
#define LASTEST_IMAGE_PATH @"lastest_image_path"

#define PATH @"path"
#define THUMB_PATH @"thumb_path"
#define TYPE @"type"
#define ALBUM_NAME @"album_name"
#define ALBUM_ID @"album_id"


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
    _storage = nil;
}

/**
 新建相册
 */
- (void)insertAlbum:(NSString *)albumName {
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:InsertAlbumSQL, albumName, 1, 1];
        [db executeUpdate:sql];
    }];
    
}

- (void)insertAlbum:(NSString *)albumName withType: (NSInteger)type {
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:InsertAlbumSQL, albumName, 1, type];
        [db executeUpdate:sql];
    }];
    
}

/// 新建fake相薄QueryLastestAlbumSQL
- (void)insertFakeAlbum:(NSString *)albumName {
    
}

- (NSArray<TAlbumObject *> *)queryAlbum:(NSInteger)state {
    NSMutableArray *albumArray = [NSMutableArray array];
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet* rs = [db executeQuery:QueryAlbumSQL];
            while ([rs next]) {
                [albumArray addObject: [self getAlbumByRestultSet:rs]];
            }
    }];
        
    return [NSArray arrayWithArray:albumArray];
}

- (BOOL)updateAlbumPhotoCount:(NSInteger)albumId andCount:(NSInteger)photoCount {
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:UpdateAlbumPhotoCountSQL, photoCount, albumId];
        
        BOOL flag = [db executeUpdate:sql];
        if (flag) {
            NSLog(@"error");
        }
        
    }];
    return YES;
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

/**
 把ResultSet转为TAlbumObject对象
 */
- (TAlbumObject *)getAlbumByRestultSet:(FMResultSet *)rs {
    
    TAlbumObject *albumObj = [[TAlbumObject alloc]init];
    albumObj.id = [rs intForColumn:ROWID];
    albumObj.name = [rs stringForColumn:NAME];
    albumObj.state = [rs intForColumn:STATE];
    albumObj.photoCount = [rs intForColumn:PHOTO_COUNT];
    albumObj.lastestImagePath = [rs stringForColumn:LASTEST_IMAGE_PATH];
    return albumObj;
    
}

- (BOOL)insertPicture:(TPictureAudioObject *)obj {
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSString *sql = [NSString stringWithFormat:InsertPictureSQL, obj.name, obj.path, obj.thumbPath, obj.type, obj.state, obj.albumName, obj.albumId];
        BOOL flag = [db executeUpdate:sql];
        NSLog(@" insert picture %d", flag);
    }];
    return NO;
}

- (NSArray *)queryPicture:(NSInteger)state andAlbumId:(NSInteger)albumId {
    NSMutableArray *pictureArray = [NSMutableArray array];
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:QueryPictureWithAlbumIdSQL, albumId];
        FMResultSet* rs = [db executeQuery:sql];
        while ([rs next]) {
            [pictureArray addObject:[self getPictureAudioByResultSet:rs]];
        }
    }];
    return [NSArray arrayWithArray:pictureArray];
}

/**
 把ResultSet转为TPictureAudioObject对象
 */
- (TPictureAudioObject *)getPictureAudioByResultSet:(FMResultSet *)rs {
    TPictureAudioObject *pictureObj = [[TPictureAudioObject alloc]init];
    [pictureObj setId:[rs intForColumn:ROWID]];
    [pictureObj setName:[rs stringForColumn:NAME]];
    [pictureObj setPath:[rs stringForColumn:PATH]];
    [pictureObj setThumbPath:[rs stringForColumn:THUMB_PATH]];
    [pictureObj setType: [rs intForColumn:TYPE]];
    [pictureObj setState:[rs intForColumn:STATE]];
    [pictureObj setAlbumId:[rs intForColumn:ALBUM_ID]];
    [pictureObj  setAlbumName:[rs stringForColumn:ALBUM_NAME]];
    return pictureObj;
}

- (void)updateAlbumPhotoCount:(NSInteger)albumId {
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:QueryAlbumPhotoCount, albumId];
        FMResultSet* rs = [db executeQuery:sql];
        while ([rs next]) {
            int photoCount = [rs intForColumnIndex:0];
            NSString *updateSql = [NSString stringWithFormat:UpdateAlbumPhotoCountSQL, photoCount+1, albumId];
            [db executeUpdate:updateSql];
            
            break;
        }
        
        [rs close];
        
    }];
}

/// 更新Album表的封面照片地址
/// - Parameter imagePath: 照片地址
- (void)updateAlbumLastestImagePath:(NSString *)imagePath albumId:(NSInteger)albumId {

    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *sql = [NSString stringWithFormat:UpdateAlbumLastestImagePath, imagePath, albumId];
        
        BOOL flag = [db executeUpdate:sql];
        if (!flag) {
            NSLog(@"error*");
        }
    }];
}

@end


///Users/lixiaodong/Library/Developer/CoreSimulator/Devices/ED3E65E6-19F0-4B80-89C6-3AAC04433E82/data/Containers/Data/Application/BD886511-3869-4B88-9FC4-AD44CD4DBD67/Documents/thumb/B6A55916-08E7-4ADA-AAF4-ED139FAF51D2_L0_001.PNG
///
////Users/lixiaodong/Library/Developer/CoreSimulator/Devices/ED3E65E6-19F0-4B80-89C6-3AAC04433E82/data/Containers/Data/Application/BD886511-3869-4B88-9FC4-AD44CD4DBD67/Documents/thumb/B6A55916-08E7-4ADA-AAF4-ED139FAF51D2_L0_001.PNG
