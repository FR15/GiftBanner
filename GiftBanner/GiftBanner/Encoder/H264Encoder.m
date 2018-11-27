//
//  H264Encoder.m
//  GiftBanner
//
//  Created by Frank_s on 2018/11/26.
//  Copyright © 2018 Frank_s. All rights reserved.
//

#import "H264Encoder.h"


/*
 
 硬编码
 @para - session
 @para - imageBuffer : 待压缩的 video frame
 @para - presentationTimeStamp : 该 frame 时间戳
 @para - duration : 该 frame 时长
 @para - frameProperties :
 @para - sourceFrameRefcon :
 @para - infoFlagsOut :
 
 @return - status
 
 OSStatus VTCompressionSessionEncodeFrame(VTCompressionSessionRef session, CVImageBufferRef imageBuffer, CMTime presentationTimeStamp, CMTime duration, CFDictionaryRef frameProperties, void *sourceFrameRefcon, VTEncodeInfoFlags *infoFlagsOut);
 
 
 
 
 创建一个压缩会话
 compressed frames ara emitted through calls to outputCallback
 @para - allocator                   : NULL
 @para - width                       : The pixel width of video frames.
 @para - height                      : The pixel height of video frames.
 @para - codecType                   : The codec type.
 @para - encoderSpecification        : NULL
 @para - sourceImageBufferAttributes :
 @para - compressedDataAllocator     : NULL
 @para - outputCallback              : 回调，包含压缩的 frame
 @para - outputCallbackRefCon        : 引用一个值，会传入回调中(一般为self)
 @para - compressionSessionOut       : 创建的压缩会话)
 
 @return - status
 
 OSStatus VTCompressionSessionCreate(CFAllocatorRef allocator, int32_t width, int32_t height, CMVideoCodecType codecType, CFDictionaryRef encoderSpecification, CFDictionaryRef sourceImageBufferAttributes, CFAllocatorRef compressedDataAllocator, VTCompressionOutputCallback outputCallback, void *outputCallbackRefCon, VTCompressionSessionRef  _Nullable *compressionSessionOut);

 
 
 outputCallback
 
 @para - outputCallbackRefCon :
 @para - sourceFrameRefCon    :
 @para - status
 @para - infoFlags
 @para - sampleBuffer  : Contains the compressed frame if compression was successful and the frame was not dropped; otherwise, NULL.
 
 typedef void (*VTCompressionOutputCallback)(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer);

 
 
 */

// compressionOutputCallback
void compressionOutputCallback(void *outputCallbackRefCon, void *sourceFrameRefCon, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer) {
  
  if (status != 0) return;
  
  H264Encoder *encoder = (__bridge H264Encoder *)outputCallbackRefCon;
  [encoder compressCallbackWithSampleBuffer:sampleBuffer];
}


@implementation H264Encoder
{
  VTCompressionSessionRef _encodingSession;
  CMFormatDescriptionRef _formatDesc;
  CMSampleTimingInfo *_timingInfo;
  
  int _frameCount;
  
  NSMutableData *_h264;
  
  NSData *_sps;
  NSData *_pps;
  
}

- (void) log {
  
  
  
}


// 编码配置
- (void)encodingSessionWithPixelSize:(CGSize)pixelSize {
  
  OSStatus status = VTCompressionSessionCreate(NULL, pixelSize.width, pixelSize.height, kCMVideoCodecType_H264, NULL, NULL, NULL, compressionOutputCallback, (__bridge void * _Nullable)(self), &_encodingSession);
  
  if (status != noErr) {
    NSLog(@"ERROR: ....... encoding session create error");
    return;
  }
  
  
  // 在编码之前执行一些初始化操作
  VTCompressionSessionPrepareToEncodeFrames(_encodingSession);
}
// 编码
- (void)encodeWithImageBuffer:(CVImageBufferRef)imageBuffer presentationTimeStamp:(CMTime)presentationTimeStamp presentationDuration:(CMTime)presentationDuration {
  VTEncodeInfoFlags flags;
  VTCompressionSessionEncodeFrame(_encodingSession, imageBuffer, presentationTimeStamp, presentationDuration, NULL, NULL, &flags);
}


// 编码后的 CMSampleBuffer
// CMTime
// CMVdieoFormatDesc
// CMBlockBuffer

// 将编码后H264数据
- (void)compressCallbackWithSampleBuffer:(CMSampleBufferRef)samplebuffer {
  
  if (!CMSampleBufferDataIsReady(samplebuffer)) return;
  
  NSArray *attachmentsArray = CFBridgingRelease(CMSampleBufferGetSampleAttachmentsArray(samplebuffer, true));
  
  
  // sps pps
  CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(samplebuffer);
  size_t sparameterSetSize, sparameterSetCount;
  const uint8_t *sparameterSet;
  // videoDesc               :CMFormatDescriptionRef
  // parameterSetIndex       :
  // parameterSetPointerOut
  // parameterSetSizeOut
  // parameterSetCountOut
  // NALUnitHeaderLengthOut
  OSStatus status = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0);
  if (status == noErr) {
    size_t pparameterSetSize, pparameterSetCount;
    const uint8_t *pparameterSet;
    status = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0);
    if (status == noErr) {
      _sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
      _pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
      
      [_h264 appendBytes:_sps.bytes length:_sps.length];
      [_h264 appendBytes:_pps.bytes length:_pps.length];
    }
  }
  
  // Returns a CMSampleBuffer's CMBlockBuffer of media data.
  CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(samplebuffer);
  size_t length, totalLength;
  char *dataPointer;
  
  //
  // theBuffer  : CMBlockBuffer , must not be NULL
  // offset     : 偏移量
  // lengthAtOffset : 偏移量剩余的可用数据长度
  // totalLength : CMBlockBuffer total length
  // dataPointer :
  
  status = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataBuffer);
  // 一个循环取值的过程
  if (status == noErr) {
    size_t bufferOffset = 0;
    static const int AVCCHeaderLength = 4;
    while (bufferOffset < totalLength - AVCCHeaderLength) {
      uint32_t NALULength = 0;
      memcpy(&NALULength, dataPointer + bufferOffset, AVCCHeaderLength);
      NALULength = CFSwapInt32BigToHost(NALULength);
      NSData *data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALULength];
      [_h264 appendBytes:data.bytes length:data.length];
      bufferOffset += AVCCHeaderLength + NALULength;
    }
  }
}

// sps\pps + CMBlockBuffer + CMTimer
//

// h264 data -> log data

@end
