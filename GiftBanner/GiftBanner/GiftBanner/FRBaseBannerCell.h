//
//  FRBaseBannerCell.h
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import <UIKit/UIKit.h>

// 为了方便扩展，支持多种不同的 model 对应多种不同cell

NS_ASSUME_NONNULL_BEGIN

@protocol FRBannerModelProtocol;
@class FRBaseBannerCell;

@protocol FRBannerCellDelegate <NSObject>

- (void)dismissOfBannerCell:(FRBaseBannerCell *)cell;

@end


@interface FRBaseBannerCell : UIView

@property (nonatomic, copy) NSString *reuseIdentifer;
@property (nonatomic, readonly, strong) id<FRBannerModelProtocol> model;
@property (nonatomic, readonly, assign, getter=isDisplaying) BOOL displaying; // 是否处于展示状态
@property (nonatomic, weak) id<FRBannerCellDelegate> delegate;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)displayWithModel:(id<FRBannerModelProtocol>)model;
- (void)dismiss;
- (void)animationForDisplay;
- (void)animationForDismiss;
- (void)reset; 

@end

NS_ASSUME_NONNULL_END
