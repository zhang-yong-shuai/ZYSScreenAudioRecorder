//
//  JKScreenRecorder.m
//  JKScreenRecorder
//
//  Created by Jakey on 2017/2/5.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ZYSScreenRecorder.h"

@interface ZYSScreenRecorder ()

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSString *videoPath;

@property (nonatomic, copy) ZYSScreenRecording screenRecording;
@property (nonatomic, copy) ZYSScreenRecordStop screenRecordStop;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;

@property (nonatomic, assign) BOOL isPausing;

@end

@implementation ZYSScreenRecorder

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        // set default frame rate to 24.
        self.frameRate = 24;
        self.duration = 0;
        self.isPausing = false;
    }
    
    return self;
}

#pragma mark - start / stop
- (void)startRecording {
    NSLog(@"录制开始");
    if (self.isPausing == NO) {
        [self setupVideoWriter];
    }
    
    self.isPausing = false;
    
    // init timer
    NSDate *nowDate = [NSDate date];
    self.timer = [[NSTimer alloc] initWithFireDate:nowDate interval:1.0 / self.frameRate target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)pauseRecording {
    self.isPausing = true;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)stopRecordingWithHandler:(ZYSScreenRecordStop)handler {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [self.videoWriterInput markAsFinished];
    [self.videoWriter finishWritingWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (handler) {
                handler(self.videoPath);
            }
        });
        
        self.adaptor = nil;
        self.videoWriterInput = nil;
        self.videoWriter = nil;
    }];
}

#pragma mark - recording method, send duration
- (void)screenRecording:(ZYSScreenRecording)screenRecording {
    self.screenRecording = [screenRecording copy];
}

#pragma mark - private methods
- (void)drawFrame {
    self.duration += 1.0 / self.frameRate;
    [self makeFrame];

    if (self.screenRecording) {
        __weak typeof (self) weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.screenRecording(weakself.duration);
        });
    }
}

/// make per frame
- (void)makeFrame {
    self.frameCount++;
    CMTime frameTime = CMTimeMake(self.frameCount, (int32_t)self.frameRate);
    [self appendVideoFrameAtTime:frameTime];
}


/// append image to video
- (void)appendVideoFrameAtTime:(CMTime)frameTime {
    CGImageRef newImage = [self fetchScreenshot].CGImage;
    
    if (![self.videoWriterInput isReadyForMoreMediaData]) {
        NSLog(@"Not ready for video data");
    } else {
        if (self.adaptor.assetWriterInput.readyForMoreMediaData) {
            NSLog(@"Processing video frame (%zd)", self.frameCount);
            
            CVPixelBufferRef buffer = [self pixelBufferFromCGImage:newImage];
            if(![self.adaptor appendPixelBuffer:buffer withPresentationTime:frameTime]){
                NSError *error = self.videoWriter.error;
                if(error) {
                    NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                }
            }
            CVPixelBufferRelease(buffer);
        } else {
            printf("adaptor not ready %zd\n", self.frameCount);
        }
        NSLog(@"**************************************************");
    }
}

/// init video writer
- (BOOL)setupVideoWriter {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    self.videoPath = [documents stringByAppendingPathComponent:@"video.mp4"];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:nil];
    
    NSError *error;
    
    // Configure videoWriter
    NSURL *fileUrl = [NSURL fileURLWithPath:self.videoPath];
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:fileUrl fileType:AVFileTypeMPEG4 error:&error];
    NSParameterAssert(self.videoWriter);
    
    // Configure videoWriterInput
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:size.width * size.height], AVVideoAverageBitRateKey, nil];
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: @(size.width),
                                    AVVideoHeightKey: @(size.height),
                                    AVVideoCompressionPropertiesKey: videoCompressionProps};
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSParameterAssert(self.videoWriterInput);
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    self.adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriterInput sourcePixelBufferAttributes:bufferAttributes];
    
    // add input
    [self.videoWriter addInput:self.videoWriterInput];
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    return YES;
}

/// image => PixelBuffer
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,frameWidth,frameHeight,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameWidth, frameHeight, 8,CVPixelBufferGetBytesPerRow(pxbuffer),rgbColorSpace,(CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0,frameWidth,frameHeight),  image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

/// view => screen shot image
- (UIImage *)fetchScreenshot {
    UIImage *image = nil;
    
    if (self.captureLayer) {
        NSLock *aLock = [NSLock new];
        [aLock lock];
        
        CGSize imageSize = self.captureLayer.bounds.size;
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.captureLayer renderInContext:context];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [aLock unlock];
    }
    
    return image;
}


@end
