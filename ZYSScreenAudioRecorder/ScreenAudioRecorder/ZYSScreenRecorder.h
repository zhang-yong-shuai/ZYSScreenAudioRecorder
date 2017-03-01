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

typedef void(^ZYSScreenRecording)(NSTimeInterval duration);
typedef void(^ZYSScreenRecordStop)(NSString *videoPath);

@interface ZYSScreenRecorder : NSObject

// reqeuired, captue view
@property (nonatomic, strong) CALayer *captureLayer;

// optional, frame per second
@property (nonatomic, assign) NSInteger frameRate;

// total duration
@property (nonatomic, readonly) NSTimeInterval duration;

// video path
@property (nonatomic, readonly) NSString *videoPath;


// start
- (void)startRecording;

// pause
- (void)pauseRecording;

// stopRecording
- (void)stopRecordingWithHandler:(ZYSScreenRecordStop)handler;

// recording, can get duration
- (void)screenRecording:(ZYSScreenRecording)screenRecording;

@end
