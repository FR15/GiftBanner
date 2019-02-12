//
//  TMLazyReusePool.m
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import "TMLazyReusePool.h"
#import "TMUtils.h"

@interface TMLazyReusePool ()
{
    // [reuseID: [views]]
    NSMutableDictionary <NSString *, NSMutableSet *> *_reuseDict;
}
@end

@implementation TMLazyReusePool

- (instancetype)init {
    self = [super init];
    if (self) {
        _reuseDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addView:(UIView *)view reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (reuseIdentifier == nil || reuseIdentifier.length == 0 || view == nil) return;
    
    NSMutableSet *reuseSet = [_reuseDict tm_safeObjectForKey:reuseIdentifier];
    if (!reuseSet) {
        reuseSet = [NSMutableSet set];
        [_reuseDict setObject:reuseSet forKey:reuseIdentifier];
    }
    [reuseSet addObject:view];
}

- (UIView *)dequeueViewForReuseIdentifier:(NSString *)reuseIdentifier {
    
    if (reuseIdentifier == nil || reuseIdentifier.length == 0) return nil;
    
    UIView *ret;
    NSMutableSet *reuseSet = [_reuseDict objectForKey:reuseIdentifier];
    if (reuseSet && reuseSet.count > 0) {
        ret = [reuseSet anyObject];
        [reuseSet removeObject:ret];
    }
    return ret;
}

- (void)clear {
    [_reuseDict removeAllObjects];
}

@end
