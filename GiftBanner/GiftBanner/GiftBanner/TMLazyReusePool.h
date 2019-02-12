//
//  TMLazyReusePool.h
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMLazyReusePool : NSObject

// 将 view 添加到复用池
- (void)addView:(UIView *)view reuseIdentifier:(NSString *)reuseIdentifier;
// 从复用池中取 view
- (UIView *)dequeueViewForReuseIdentifier:(NSString *)reuseIdentifier;
// 清空复用池
- (void)clear;

@end

NS_ASSUME_NONNULL_END

// 1. 构建复用池
// 2. 构建 base cell
// 3. 构建闭环
// 4. 管理类

// 替换逻辑
// 排序逻辑

//  --------insert------>display-------->animation
//            |             ↑              |
//            |             |              |
//            ↓             |              |
//        WaitQueue ------->|              |
//                          |              |
//                          |              |
//                          |              ↓
//                      animation<-------dismiss
