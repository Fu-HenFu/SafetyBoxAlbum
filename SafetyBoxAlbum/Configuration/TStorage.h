//
//  TStorage.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//

#import <Foundation/Foundation.h>

#import "TAlbumObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TStorage : NSObject

+ (instancetype)shareStorage;
- (void)close;

- (void)insertAlbum:(NSString *)albumName;
- (void)insertFakeAlbum:(NSString *)albumName;

- (TAlbumObject *)getLastestAlbumResultSet;
@end

NS_ASSUME_NONNULL_END
