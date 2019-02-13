//
//  FRBannerNormalCell.h
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import "FRBaseBannerCell.h"

NS_ASSUME_NONNULL_BEGIN

// cell 在调整 frame 时
//
// cell 在 dismiss animation 时，就不应该再添加 model

typedef NS_ENUM(NSUInteger, FRBannerNormalCellState) {
    FRBannerNormalCellStateNone, // cell 处于待展示状态
    FRBannerNormalCellStateDisplaying, // cell处于展示动画中
    FRBannerNormalCellStateDisplayed,  // cell已经完全展示出来
    FRBannerNormalCellStateAnimation,  // cell叠加中
    FRBannerNormalCellStateDismiss,    // cell dismiss animation
};

@interface FRBannerNormalCell : FRBaseBannerCell

- (void)increasingWithModel:(id<FRBannerModelProtocol>)model;

@end

NS_ASSUME_NONNULL_END
