//
//  FRBannerModelProtocol.h
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FRBannerModelProtocol <NSObject>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) NSInteger g_type; // 0-normal
@property (nonatomic, assign) NSInteger g_id;
@property (nonatomic, assign) float     g_duration;
@property (nonatomic, assign) NSInteger g_bef_count; // 之前的数量，叠加
@property (nonatomic, assign) NSInteger g_cur_count; // 当前的数量，展示
@property (nonatomic, assign) NSInteger u_id;
@property (nonatomic, strong) NSDate   *g_date;

@end

NS_ASSUME_NONNULL_END
