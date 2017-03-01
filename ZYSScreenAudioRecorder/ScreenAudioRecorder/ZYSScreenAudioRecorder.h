//
//  ZYSScreenAudioRecorder.h
//  ZYSScreenAudioRecorder
//
//  Created by zys on 2017/2/28.
//  Copyright © 2017年 XiYiChangXiang. All rights reserved.
//

/**
 *  Screen Audio Recroder
 */

#import <UIKit/UIKit.h>
#import "ZYSScreenRecorder.h"

@interface ZYSScreenAudioRecorder : NSObject

@property (nonatomic, strong) CALayer *recordingLayer;

/// init with a recording view.
- (instancetype)initWithRecordLayer:(CALayer *)layer;

/// start recording
- (void)startRecording;

/// pause recording
- (void)pauseRecording;

/// stop recording
- (void)stopRecordingWithHandler:(ZYSScreenRecordStop)handler;

/// recording, can get duration
- (void)screenRecording:(ZYSScreenRecording)screenRecording;

@end
