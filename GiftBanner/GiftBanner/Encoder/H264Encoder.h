//
//  H264Encoder.h
//  GiftBanner
//
//  Created by Frank_s on 2018/11/26.
//  Copyright © 2018 Frank_s. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface H264Encoder : NSObject

- (void)compressCallbackWithSampleBuffer:(CMSampleBufferRef)samplebuffer;

@end

NS_ASSUME_NONNULL_END
