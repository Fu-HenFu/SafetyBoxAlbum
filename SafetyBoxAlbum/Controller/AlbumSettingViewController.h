//
//  AlbumSettingViewController.h
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2024/12/25.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef void (^UpdateAlbumCountBlock)(NSInteger count, UIImage *lastestImage);

@interface AlbumSettingViewController : UIViewController <UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, copy) UpdateAlbumCountBlock updateAlbumCountBlock;
- (instancetype)initWithAlbumId:(NSInteger)albumId andAlbumName:(NSString *)albumName;

- (void)albumInfo:(NSInteger)albumId andAlbumName:(NSString *)albumName;

@end
