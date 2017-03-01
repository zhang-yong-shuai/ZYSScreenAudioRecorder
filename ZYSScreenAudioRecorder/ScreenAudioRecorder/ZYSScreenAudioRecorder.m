//
//  ZYSScreenAudioRecorder.m
//  ZYSScreenAudioRecorder
//
//  Created by zys on 2017/2/28.
//  Copyright © 2017年 XiYiChangXiang. All rights reserved.
//

#import "ZYSScreenAudioRecorder.h"
#import "ZYSAudioRecorder.h"
#import "ZYSRecorderUtils.h"

@interface ZYSScreenAudioRecorder ()

@property (nonatomic, strong) ZYSScreenRecorder *screenRecorder;
@property (nonatomic, strong) ZYSAudioRecorder *audioRecorder;

@end

@implementation ZYSScreenAudioRecorder

#pragma mark - life cycle
- (instancetype)initWithRecordView:(UIView *)view {
    if (self = [super init]) {
        self.recordingView = view;
    }
    
    return self;
}

#pragma mark - record operations
/// start recording
- (void)startRecording {
    [self.screenRecorder startRecordingWithCapture];
    [self.screenRecorder screenRecording:^(NSTimeInterval duration) {
        NSLog(@"时间: %.2lf", duration);
    }];
    
    [self.audioRecorder startRecord];
}

/// pause recording
- (void)pauseRecording {
    [self.screenRecorder pauseRecording];
    [self.audioRecorder pauseRecord];
}

/// stop recording
- (void)stopRecordingWithHandler:(ZYSScreenRecordStop)handler {
    [self.audioRecorder stopRecord];
    [self.screenRecorder stopRecordingWithHandler:^(NSString *videoPath) {
        // merge video and audio
        [ZYSRecorderUtils mergeVideo:self.screenRecorder.videoPath andAudio:self.audioRecorder.audioPath withCompletion:^(NSString *exportVideoPath) {
            NSLog(@"视频合成成功！");
            
            if (exportVideoPath) {
                if (handler) {
                    handler(exportVideoPath);
                }
            }
        }];
    }];
}

#pragma mark - Getters
- (ZYSScreenRecorder *)screenRecorder {
    if (!_screenRecorder) {
        _screenRecorder = [ZYSScreenRecorder new];
        _screenRecorder.captureView = self.recordingView;
    }
    
    return _screenRecorder;
}

- (ZYSAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        _audioRecorder = [ZYSAudioRecorder new];
    }
    
    return _audioRecorder;
}

@end
