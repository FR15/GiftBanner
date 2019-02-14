//
//  FRBannerManagerView.m
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import "FRBannerManagerView.h"
#import "FRBannerModelProtocol.h"
#import "TMLazyReusePool.h"
#import "FRBaseBannerCell.h"
#import "FRBannerNormalCell.h"

static NSString *BannerNormalCell = @"BannerNormalCell";

@interface FRBannerManagerView ()<FRBannerCellDelegate>
{
    NSInteger _maxDisplayingCellCount;
    
    NSMutableArray<id<FRBannerModelProtocol>> *_waitingArr;
    
    NSMutableArray<FRBaseBannerCell *> *_displayingCellArr;
    
    TMLazyReusePool *_reusePool;
}
@end

@implementation FRBannerManagerView

- (instancetype)initWithFrame:(CGRect)frame maxDisplayingCellCount:(NSInteger)maxCount {
    self = [super initWithFrame:frame];
    if (self) {
        _maxDisplayingCellCount = maxCount;
        _waitingArr = [NSMutableArray array];
        _displayingCellArr = [NSMutableArray arrayWithCapacity:_maxDisplayingCellCount];
        _reusePool = [[TMLazyReusePool alloc] init];
    }
    return self;
}

- (void)insertMsg:(id<FRBannerModelProtocol>)model {

    // 判断是否是 叠加
    // TODO: 这里对 model 类型做判断
    if (model.g_bef_count == 0) { // new banner
        if (_displayingCellArr.count < _maxDisplayingCellCount) {
            [self __displayingCellWithModel:model];
        } else {
            [_waitingArr addObject:model];
        }
    } else if(model.g_bef_count > 0) { // 进入此代码区的 model 都是可叠加的
        
        // 同样的 model.identifier
        // 意味着同一个人送的同一种礼物
        // 只要取得时间最近的一个直接叠加，以此判定这是一个叠加的横幅
        FRBaseBannerCell *temCell;
        NSInteger index = -100;
        NSInteger i = _displayingCellArr.count-1;
        for (; i>=0; i--) {
            FRBaseBannerCell *cell = _displayingCellArr[i];
            if ([cell.model.identifier isEqualToString:model.identifier]) {
                temCell = cell;
                index = i;
                break;
            }
        }
        if (temCell && index >=0 && [temCell isKindOfClass:[FRBannerNormalCell class]] && !temCell.isDismissing) { // 展示队列的叠加
            // 如果此时 cell dismiss animation
            // 就不应该再放入 cell 中
            // 而是将 model 放入等待队列中
            [(FRBannerNormalCell *)temCell increasingWithModel:model];
        } else { // 待叠加的model位于等待队列中
            [self __replaceWaitingModelWithNewModel:model];
        }
    }
}
// 等待队列中的 model 是按照时间顺序依次往后排的
// 这个叠加的 model 应该从末尾往前查找
// 这样2个model之间的时间间隔才是最小的
- (void)__replaceWaitingModelWithNewModel:(id<FRBannerModelProtocol>)model {
    
    id<FRBannerModelProtocol> tem;
    NSInteger index = -100;
    NSInteger i = _waitingArr.count-1;
    
    for (; i>=0; i--) {
        id<FRBannerModelProtocol> last = _waitingArr[i];
        if ([last.identifier isEqualToString:model.identifier]) {
            tem = last;
            index = i;
            break;
        }
    }
    
    if (tem && index >= 0) {
        [_waitingArr replaceObjectAtIndex:index withObject:model];
    } else {
        model.g_bef_count = 0;
        if (_displayingCellArr.count >= _maxDisplayingCellCount)
            [_waitingArr addObject:model];
        else
            [self __displayingCellWithModel:model];
        
        // 这个 model 是一个叠加的model，但是之前的model已经丢失了
        // 丢失原因： 连击有效，但是cell已经dismiss了
        // 解决方案：将其作为一个独立的model
    }
}

- (void)__displayingCellWithModel:(id<FRBannerModelProtocol>)model {
    
    FRBaseBannerCell *cell;
    
    if (model.g_type == 0) { // 支持多种类型
        cell = (FRBannerNormalCell *)[_reusePool dequeueViewForReuseIdentifier:BannerNormalCell];
        if (!cell) cell = [[FRBannerNormalCell alloc] initWithReuseIdentifier:BannerNormalCell];
    }
    cell.delegate = self;
    cell.model = model;
    [_displayingCellArr addObject:cell];
    // TODO: 排序
    [self __displayingCellResetFrame];
    [self addSubview:cell];
    [cell banner_display];
}

- (void)__displayingCellResetFrame {
    FRBaseBannerCell *tem;
    for (int i=0; i<_displayingCellArr.count; i++) {
        FRBaseBannerCell *cell = _displayingCellArr[i];
        CGFloat y = 65.0;
        if (tem) {
            y = CGRectGetMaxY(tem.frame) + 5.0;
        }
        if (cell.isDisplaying) {
            CGRect tem_frame = cell.frame;
            tem_frame.origin.y = y;
            cell.frame = tem_frame;
        } else {
            cell.frame = CGRectMake(-260.0, y, 260.0, 50.0);
        }
        tem = cell;
    }
}

///MARK: - FRBannerCellDelegate
- (void)dismissOfBannerCell:(FRBaseBannerCell *)cell {
    
    [cell reset];
    [_reusePool addView:cell reuseIdentifier:cell.reuseIdentifer];
    [cell removeFromSuperview];
    [_displayingCellArr removeObject:cell];
    
    if (_waitingArr.count > 0) {
        id<FRBannerModelProtocol> model = _waitingArr.firstObject;
        [_waitingArr removeObject:model];
        [self __displayingCellWithModel:model];
    }
}


@end
