//
//  TSelectAlbumViewController.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/2/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SelectedDelegate <NSObject>

- (void)selectedAlbum:(NSInteger)albumID andAlbumName:(NSString *)albumName andAlbumPhotoCount:(int)photoCount;

@end

@interface TSelectAlbumViewController : UIViewController


@property (nonatomic, weak) id<SelectedDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
