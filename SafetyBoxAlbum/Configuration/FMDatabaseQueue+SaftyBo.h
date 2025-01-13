//
//  FMDatabaseQueue+SaftyBo.h
//  SafetyBoxAlbum
//
//  Created by 李晓东 on 2025/1/12.
//

#import <FMDB/FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMDatabaseQueue (SaftyBo)
+ (instancetype)shareInstense;
@end

NS_ASSUME_NONNULL_END
