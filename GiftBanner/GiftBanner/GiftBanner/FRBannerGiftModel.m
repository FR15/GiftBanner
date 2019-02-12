//
//  FRBannerGiftModel.m
//  GiftBanner
//
//  Created by Frank_s on 2019/2/12.
//  Copyright © 2019 Frank_s. All rights reserved.
//

#import "FRBannerGiftModel.h"

@implementation FRBannerGiftModel

@synthesize g_date;
@synthesize g_duration;
@synthesize g_id;
@synthesize g_type;
@synthesize identifier;
@synthesize u_id;
@synthesize g_bef_count;
@synthesize g_cur_count;

- (NSString *)description {
    return [NSString stringWithFormat:@"m: id-%@;   bef_count-%ld;  cur_count-%ld;", identifier, g_bef_count, g_cur_count];
}

@end
