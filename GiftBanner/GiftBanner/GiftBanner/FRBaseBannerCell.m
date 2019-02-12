//
//  FRBaseBannerCell.m
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import "FRBaseBannerCell.h"

@implementation FRBaseBannerCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        _reuseIdentifer = reuseIdentifier;
        self.layer.allowsGroupOpacity = NO;
    }
    return self;
}

- (void)displayWithModel:(id<FRBannerModelProtocol>)model {
    NSAssert(NO, @"不应该走基类的方法 displayWithModel");
}
- (void)dismiss {
    NSAssert(NO, @"不应该走基类的方法 dismiss");
}
- (void)reset {
    NSAssert(NO, @"不应该走基类的方法 reset");
}

- (void)animationForDisplay {
    self.alpha = 1.0;
    
    CGRect frame = self.frame;
    frame.origin.x = 0.0;
    self.frame = frame;
}
- (void)animationForDismiss {
    self.alpha = 0.0;
    
    CGRect frame = self.frame;
    frame.origin.y += 10.0;
    self.frame = frame;
}


@end
