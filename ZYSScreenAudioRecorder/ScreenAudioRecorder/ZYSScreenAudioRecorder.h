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

@property (nonatomic, strong) UIView *recordingView;

/// init with a recording view.
- (instancetype)initWithRecordView:(UIView *)view;

/// start recording
- (void)startRecording;

/// pause recording
- (void)pauseRecording;

/// stop recording
- (void)stopRecordingWithHandler:(ZYSScreenRecordStop)handler;

@end
