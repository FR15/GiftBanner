//
//  FRBannerTestViewController.m
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import "FRBannerTestViewController.h"
#import "FRBannerGiftModel.h"
#import "FRBannerManagerView.h"

@interface FRBannerTestViewController ()
{
    FRBannerManagerView *_mg;
}
@end

@implementation FRBannerTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mg = [[FRBannerManagerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) maxDisplayingCellCount:3];
    _mg.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_mg];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-60.0, 60, 60)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(tap) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)tap {
    
//    [self singleWithCount:1 Callback:^(FRBannerGiftModel *model) {
//        [self->_mg insertMsg:model];
//    }];
    
//    [self groupWithCount:10 gid:3689950 uid:21998333 startCount:0 callback:^(FRBannerGiftModel *model) {
//        [self->_mg insertMsg:model];
//    }];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self singleWithCount:10 Callback:^(FRBannerGiftModel *model) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self->_mg insertMsg:model];
//            });
//        }];
//    });
    
    dispatch_async(q1, ^{
        [self groupWithCount:10 gid:3689950 uid:21998333 startCount:0 callback:^(FRBannerGiftModel *model) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_mg insertMsg:model];
            });
        }];
    });
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self singleWithCount:1000 Callback:^(FRBannerGiftModel *model) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self->_mg insertMsg:model];
//            });
//        }];
//    });
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self groupWithCount:1000 gid:83728320 uid:821372738 startCount:9 callback:^(FRBannerGiftModel *model) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self->_mg insertMsg:model];
//            });
//        }];
//    });
}
// 连续性的
- (void)groupWithCount:(NSInteger)count
                    gid:(NSInteger)gid
                    uid:(NSInteger)uid
             startCount:(NSInteger)startCount
               callback:(void(^)(FRBannerGiftModel *model))callback {
    NSInteger i = 0;
    NSString *mid = [NSString stringWithFormat:@"%ld-%ld",uid, gid];
    for (; i < count; i++) {
        FRBannerGiftModel *m = [FRBannerGiftModel new];
        m.g_date = [NSDate date];
        m.g_id = gid;
        m.u_id = uid;
        m.identifier = mid;
        m.g_type = 0;
        m.g_duration = 5.0;
        m.g_cur_count = startCount + i + 1;
        m.g_bef_count = m.g_cur_count - 1;
        callback(m);
    }
}
// 一次性的
- (void)singleWithCount:(NSInteger)count Callback:(void(^)(FRBannerGiftModel *model))callback {

    NSInteger i = 0;
    for (; i < count; i++) {
        int x = arc4random()%10000;
        FRBannerGiftModel *m = [FRBannerGiftModel new];
        m.g_date = [NSDate date];
        m.g_bef_count = 0;
        m.g_type = 0;
        m.g_duration = 5.0;
        m.g_id = x + 1000;
        m.u_id = x + 10000;
        m.identifier = [NSString stringWithFormat:@"%ld-%ld", m.u_id, m.g_id];
        m.g_cur_count = x;
        callback(m);
    }
}


@end
