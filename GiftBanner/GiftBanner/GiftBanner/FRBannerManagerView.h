//
//  FRBannerManagerView.h
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRBannerModelProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface FRBannerManagerView : UIView

- (instancetype)initWithFrame:(CGRect)frame maxDisplayingCellCount:(NSInteger)maxCount;

- (void)insertMsg:(id<FRBannerModelProtocol>)model;

@end

NS_ASSUME_NONNULL_END
