//
//  AlbumSettingViewController.h
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2024/12/25.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "LGPhoto/Classes/LGPhoto.h"

typedef void (^UpdateAlbumCountBlock)(NSInteger count);

@interface AlbumSettingViewController : UIViewController <UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, LGPhotoPickerViewControllerDelegate,LGPhotoPickerBrowserViewControllerDataSource,LGPhotoPickerBrowserViewControllerDelegate>

@property (nonatomic, copy) UpdateAlbumCountBlock updateAlbumCountBlock;
- (instancetype)initWithAlbumId:(NSInteger)albumId andAlbumName:(NSString *)albumName;

- (void)albumInfo:(NSInteger)albumId andAlbumName:(NSString *)albumName;

@end
