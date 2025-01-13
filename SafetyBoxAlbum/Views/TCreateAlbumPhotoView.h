//
//  TCreateItemView.h
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2025/1/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CreateItemViewDelegate <NSObject>
- (void)itemViewDidFinishBusinessLogic;
@end

@interface TCreateAlbumPhotoView : UIView <CreateItemViewDelegate>

@property (weak, nonatomic) id <CreateItemViewDelegate> delegate;
@property (nonatomic, strong) UIButton *pictureButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *albumButton;
@end

NS_ASSUME_NONNULL_END
