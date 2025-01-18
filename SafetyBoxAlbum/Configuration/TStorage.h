//
//  TStorage.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//

#import <Foundation/Foundation.h>
#import "TPictureAudioObject.h"

#import "TAlbumObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TStorage : NSObject

+ (instancetype)shareStorage;
- (void)close;
/// 新建相册
- (void)insertAlbum:(NSString *)albumName;
- (void)insertAlbum:(NSString *)albumName withType: (NSInteger)type;
- (void)insertFakeAlbum:(NSString *)albumName;

- (NSArray<TAlbumObject *> *)queryAlbum:(NSInteger)state;
- (BOOL)updateAlbumPhotoCount:(NSInteger)albumId andCount:(NSInteger)photoCount;

- (TAlbumObject *)getLastestAlbumResultSet;

- (BOOL)insertPicture:(TPictureAudioObject *)obj;

- (NSArray *)queryPicture:(NSInteger)state andAlbumId:(NSInteger)albumId;
@end

NS_ASSUME_NONNULL_END
