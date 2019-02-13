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
    
    NSMutableArray<id<FRBannerModelProtocol>> *_displayingArr;
    
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
        _displayingArr = [NSMutableArray array];
        _displayingCellArr = [NSMutableArray arrayWithCapacity:_maxDisplayingCellCount];
        _reusePool = [[TMLazyReusePool alloc] init];
    }
    return self;
}

- (void)insertMsg:(id<FRBannerModelProtocol>)model {
    
    NSLog(@"... %@", model);

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
        // 这个 model 是一个叠加的model，但是之前的model已经丢失了
        // 丢失的原因有2个
        // 1. 开头2个model时间间隔很短，cell 还没有创建展示出来，查询不到
        // 2. 连击有效，但是cell已经dismiss了
        
        // 1. 这个最恶心，目前没有解决方案
        // 2. 可以视 model 为一个独立的model，单独展示
        BOOL isExist = NO;
        for (id<FRBannerModelProtocol> m in _displayingArr) {
            if ([model.identifier isEqualToString:m.identifier]) {
                isExist = YES;
                break;
            }
        }
        if (!isExist) {
            model.g_bef_count = 0;
            [self insertMsg:model];
        }
    }
}


- (void)__displayingCellWithModel:(id<FRBannerModelProtocol>)model {
    
    [_displayingArr addObject:model];
    
    FRBaseBannerCell *cell;
    
    if (model.g_type == 0) { // normal
        cell = (FRBannerNormalCell *)[_reusePool dequeueViewForReuseIdentifier:BannerNormalCell];
        if (!cell) cell = [[FRBannerNormalCell alloc] initWithReuseIdentifier:BannerNormalCell];
    }
    cell.delegate = self;
    //TODO: cell 排序
    [_displayingCellArr addObject:cell];
    [self __displayingCellResetFrame];
    [self addSubview:cell];
    [cell displayWithModel:model];
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

/// - FRBannerCellDelegate
- (void)dismissOfBannerCell:(FRBaseBannerCell *)cell {
    
    [cell reset];
    [_reusePool addView:cell reuseIdentifier:cell.reuseIdentifer];
    [cell removeFromSuperview];
    [_displayingCellArr removeObject:cell];
    if ([_displayingArr containsObject:cell.model]) {
        [_displayingArr removeObject:cell.model];
    }
    
    if (_waitingArr.count > 0) {
        id<FRBannerModelProtocol> model = _waitingArr.firstObject;
        [_waitingArr removeObject:model];
        [self __displayingCellWithModel:model];
    }
}


@end
