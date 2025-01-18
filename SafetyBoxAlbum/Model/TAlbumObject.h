//
//  TAlbumObject.h
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2025/1/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAlbumObject : NSObject

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, assign) NSInteger photoCount;


@end

NS_ASSUME_NONNULL_END
