//
//  FRBannerNormalCell.m
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import "FRBannerNormalCell.h"
#import "FRBannerModelProtocol.h"

// 为了保证 礼物的数量 在各个设备之间都是 一致的
// 需要后台统一礼物的数量
// 而 客户端不应该去记录、维护任何状态

@interface FRBannerNormalCell ()
{
    UIImageView *_bgIV;
    UIImageView *_giftIV;
    UILabel *_numLabel;
    UILabel *_giftLabel;
    UILabel *_senderLabel;
    NSMutableArray<id<FRBannerModelProtocol>> *_modelArr;
    NSInteger _current_count;
    FRBannerNormalCellState _state;
}
@end

@implementation FRBannerNormalCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _bgIV = [UIImageView new];
        [self addSubview:_bgIV];
        _giftIV = [UIImageView new];
        [self addSubview:_giftIV];
        
        _numLabel = [UILabel new];
        _numLabel.textColor = [UIColor redColor];
        _numLabel.layer.anchorPoint = CGPointMake(0.0, 1.0);
        _numLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_numLabel];
        
        _giftLabel = [UILabel new];
        _giftLabel.textColor = [UIColor greenColor];
        _giftLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_giftLabel];
        
        _senderLabel = [UILabel new];
        _senderLabel.textColor = [UIColor whiteColor];
        _senderLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_senderLabel];
        
        _state = FRBannerNormalCellStateNone;
        _modelArr = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _bgIV.frame = CGRectMake(0.0, 10.0, self.bounds.size.width, self.bounds.size.height-10.0);
    _giftIV.frame = CGRectMake(self.bounds.size.width-55.0, 0.0, self.bounds.size.height-10.0, self.bounds.size.height-10.0); 
    _senderLabel.frame = CGRectMake(25.0, 10.0, self.bounds.size.width-90.0, (self.bounds.size.height-10.0)*0.5);
    _giftLabel.frame = CGRectMake(25.0, CGRectGetMaxY(_senderLabel.frame), self.bounds.size.width-90.0, (self.bounds.size.height-10.0)*0.5);
}

- (BOOL)isDisplaying {
    return _state != FRBannerNormalCellStateNone;
}

- (BOOL)isDismissing {
    return _state == FRBannerNormalCellStateDismiss;
}

- (void)banner_display {
    
    if (!self.model) return;
    [self __resetWithModel:self.model];
    // 这一步会有问题
    // 问题： 调用 displayWithModel: 之后
    // cell 在展示动画
    // 此时 又直接调用 increasingWithModel:
    // 导致 展示顺序出错，而且cell展示不够优雅
    // 所以使用 state 记录
    _state = FRBannerNormalCellStateDisplaying;
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ [self animationForDisplay]; }
                     completion:^(BOOL finished) {
                         self->_state = FRBannerNormalCellStateDisplayed;
                         [self increasingWithModel:self.model];
                     }
     ];
}

// 累加
- (void)increasingWithModel:(id<FRBannerModelProtocol>)model {
    
    if (!model) return;
    if (![model.identifier isEqualToString:self.model.identifier]) return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (_state == FRBannerNormalCellStateDisplaying || _state == FRBannerNormalCellStateAnimation) {
        // 这一步会有问题
        // 正常情况下，model 是以时间顺序依次加入 arr
        // 但是因为网络问题，不能保证 接收到的 model 一定是按照时间顺序的
        // 会导致 在叠加的过程中，数字忽大忽小
        // 所以，要添加 model count 判断
        [_modelArr addObject:model];
    } else {
        _state = FRBannerNormalCellStateAnimation;
        [self __increasingAnimationWithCount:model.g_cur_count completion:^{
            [self __completionHandlerWithDuration:model.g_duration];
        }];
    }
}
// 叠加动画
- (void)__increasingAnimationWithCount:(NSInteger)count completion:(void(^)(void))completionHandler {
    
    _current_count = count;
    
    _numLabel.text = [NSString stringWithFormat:@"x %ld", count];
    CGSize tem_size = [_numLabel sizeThatFits:CGSizeZero];
    if (!CGSizeEqualToSize(_numLabel.bounds.size, tem_size)) {
        _numLabel.frame = CGRectMake(self.bounds.size.width, self.bounds.size.height-tem_size.height, tem_size.width, tem_size.height);
    }
    if (!CGAffineTransformIsIdentity(_numLabel.transform)) {
        [_numLabel.layer removeAllAnimations];
    }
    _numLabel.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.12
                          delay:0.0
         usingSpringWithDamping:1
          initialSpringVelocity:1.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{ self->_numLabel.transform = CGAffineTransformMakeScale(1.3, 1.3); }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.2 animations:^{
                             self->_numLabel.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                             self->_state = FRBannerNormalCellStateDisplayed;
                             if (completionHandler) completionHandler();
                         }];
                     }
     ];
}
// 闭环
- (void)__completionHandlerWithDuration:(float)duration {
    if (_modelArr.count > 0) {
        id<FRBannerModelProtocol> model = _modelArr.firstObject;
        [_modelArr removeObject:model];
        // 这里要求数字只能递增
        if (model.g_cur_count > _current_count) {
            [self increasingWithModel:model];
        } else {
            [self __completionHandlerWithDuration:duration];
        }
    } else {
        [self performSelector:@selector(__dismissAnimation) withObject:nil afterDelay:duration]; //延迟dismiss
    }
}

- (void)__dismissAnimation {
    
    // 这一步有问题
    // 此时 cell 开始 dismiss animation
    // cell 在 dismiss 时如果又 insert model
    // 就会造成展示这个 model 可能展示不出来
    // 需要更具 state 做判断
    _state = FRBannerNormalCellStateDismiss;
    
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{ [self animationForDismiss]; }
                     completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(dismissOfBannerCell:)])
                             [self.delegate dismissOfBannerCell:self];
                     }
     ];
}

- (void)reset {
    [self __resetWithModel:nil];
}

- (void)__resetWithModel:(id<FRBannerModelProtocol>)model {
    _state = FRBannerNormalCellStateNone;
    if (model) {
        _bgIV.image = [UIImage imageNamed:@"bg"];
        _giftIV.image = [UIImage imageNamed:@"rocket"];
        _senderLabel.text = [NSString stringWithFormat:@"usr: %ld", model.u_id];
        _giftLabel.text = [NSString stringWithFormat:@"gift: %ld", model.g_id];
    } else {
        self.model = nil;
        [_modelArr removeAllObjects];
        _current_count = 0;
        _bgIV.image = nil;
        _giftIV.image = nil;
        _senderLabel.text = nil;
        _giftLabel.text = nil;
        _numLabel.text = nil;
        self.delegate = nil;
    }
}

@end
