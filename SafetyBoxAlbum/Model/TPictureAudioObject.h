//
//  TPictureAudioObject.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TPictureAudioObject : NSObject

@property (assign, nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, assign) NSInteger albumId;
	
@end

NS_ASSUME_NONNULL_END
