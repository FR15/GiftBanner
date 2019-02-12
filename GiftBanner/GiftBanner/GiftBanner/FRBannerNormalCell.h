//
//  FRBannerNormalCell.h
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import "FRBaseBannerCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FRBannerNormalCellState) {
    FRBannerNormalCellStateNone, //
    FRBannerNormalCellStateDisplaying, // cell处于展示动画中
    FRBannerNormalCellStateDisplayed,  // cell已经完全展示出来
    FRBannerNormalCellStateAnimation,  // cell叠加中
    
    
};

@interface FRBannerNormalCell : FRBaseBannerCell

- (void)increasingWithModel:(id<FRBannerModelProtocol>)model;

@end

NS_ASSUME_NONNULL_END
