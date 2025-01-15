//
//  AlbumHeaderView.m
//  AlbumSafetyBox
//
//  Created by Tom‘s MacBook on 2024/12/26.
//

#import "AlbumHeaderView.h"

@interface AlbumHeaderView ()

@end

@implementation AlbumHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
    }
    return self;
}

@end
