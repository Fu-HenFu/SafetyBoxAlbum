//
//  TAlbumCollectionViewCell.h
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2024/12/22.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import <Foundation/Foundation.h>

@protocol AlbumClickDelegate <NSObject>

- (void)myCustomCollectionViewCell:(UICollectionViewCell *)cell didTapButton:(UIImageView *)imageView;

- (void)showAlbumClick:(UICollectionViewCell *)cell didTapButton:(NSString *)albumName;
- (void)showAlbumToosClick:(UICollectionViewCell *)cell;

@end


@interface TAlbumCollectionViewCell : UICollectionViewCell <AlbumClickDelegate>

@property (nonatomic, weak) id<AlbumClickDelegate> delegate;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) NSString *albumName;

- (void)labelTapped:(UITapGestureRecognizer *)gestureRecognizer;
- (void)imageViewTapped:(UITapGestureRecognizer *)gestureRecognizer;
- (void)setAlbumCell:(NSString *)albumName withCoverImage:(NSString *)imagePath;

@end

