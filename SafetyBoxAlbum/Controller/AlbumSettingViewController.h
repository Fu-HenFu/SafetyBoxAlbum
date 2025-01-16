//
//  AlbumSettingViewController.h
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2024/12/25.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "LGPhoto/Classes/LGPhoto.h"

@interface AlbumSettingViewController : UIViewController <UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, LGPhotoPickerViewControllerDelegate,LGPhotoPickerBrowserViewControllerDataSource,LGPhotoPickerBrowserViewControllerDelegate>

- (instancetype)initWithAlbumId:(NSInteger)albumId andAlbumName:(NSString *)albumName;

- (void)albumInfo:(NSInteger)albumId andAlbumName:(NSString *)albumName;

@end
