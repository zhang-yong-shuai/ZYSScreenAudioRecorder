//
//  JKScreenRecorder.h
//  JKScreenRecorder
//
//  Created by Jakey on 2017/2/5.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

/**
 *  Screen Recorder
 */

#import <Foundation/Foundation.h>

typedef void(^JKScreenRecording)(NSTimeInterval duration);
typedef void(^JKScreenRecordStop)(NSString *videoPath, NSError *error);

@interface JKScreenRecorder : NSObject

// reqeuired, captue view
@property (nonatomic, strong) UIView *captureView;

// optional, frame per second
@property (nonatomic, assign) NSInteger frameRate;

// total duration
@property (nonatomic, readonly) NSTimeInterval duration;

// video path
@property (nonatomic, readonly) NSString *videoPath;


// start
- (void)startRecordingWithCapture;

// pause
- (void)pauseRecording;

// stopRecording
- (void)stopRecordingWithHandler:(JKScreenRecordStop)handler;

// recording, can get duration
- (void)screenRecording:(JKScreenRecording)screenRecording;

@end
