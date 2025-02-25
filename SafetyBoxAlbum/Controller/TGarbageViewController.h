//
//  TGarbageViewController.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/2/24.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^UpdateAlbumCountBlock)(NSInteger count, UIImage *lastestImage);
typedef void (^UpdateDestinationAlbumCountBlock)(NSInteger albumId, NSInteger count, UIImage *lastestImage);
@interface TGarbageViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, copy) UpdateAlbumCountBlock updateAlbumCountBlock;
@property (nonatomic, copy) UpdateDestinationAlbumCountBlock updateDestinationAlbumCountBlock;

- (instancetype)initWithAlbumId:(NSInteger)albumId andAlbumName:(NSString *)albumName;

@end

NS_ASSUME_NONNULL_END
