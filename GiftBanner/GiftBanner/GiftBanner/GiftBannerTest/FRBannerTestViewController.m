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
    NSInteger index;
    dispatch_source_t timer1;
    dispatch_source_t timer2;
}
@end

@implementation FRBannerTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    index = 0;
    
    _mg = [[FRBannerManagerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) maxDisplayingCellCount:3];
    _mg.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_mg];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-60.0, 60, 60)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(tap:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    //
    timer1 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_queue_create("timer1", NULL));
    dispatch_source_set_timer(timer1, DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer1, ^{
        NSString *mid = @"21998333-3689950";
        FRBannerGiftModel *m = [FRBannerGiftModel new];
        m.g_date = [NSDate date];
        m.g_id = 3689950;
        m.u_id = 21998333;
        m.identifier = mid;
        m.g_type = 0;
        m.g_duration = 5.0;
        m.g_cur_count = self->index + 1;
        m.g_bef_count = m.g_cur_count - 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_mg insertMsg:m];
        });
        self->index++;
    });
    //
    timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_queue_create("timer2", NULL));
    dispatch_source_set_timer(timer2, DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer2, ^{
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_mg insertMsg:m];
        });
    });
}
- (void)tap:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        dispatch_resume(timer1);
//        dispatch_resume(timer2);
    } else {
        dispatch_suspend(timer1);
//        dispatch_suspend(timer2);
    }
    
//    NSString *mid = @"21998333-3689950";
//    FRBannerGiftModel *m = [FRBannerGiftModel new];
//    m.g_date = [NSDate date];
//    m.g_id = 3689950;
//    m.u_id = 21998333;
//    m.identifier = mid;
//    m.g_type = 0;
//    m.g_duration = 5.0;
//    m.g_cur_count = self->index + 1;
//    m.g_bef_count = m.g_cur_count - 1;
//    [self->_mg insertMsg:m];
//    self->index++;
    
}

@end
