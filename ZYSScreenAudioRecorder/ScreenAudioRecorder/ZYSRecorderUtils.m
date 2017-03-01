//
//  ZYSRecordUtils.m
//  TestScreenRecorde
//
//  Created by zys on 2017/2/28.
//  Copyright © 2017年 XiYiChangXiang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "ZYSRecorderUtils.h"

@implementation ZYSRecorderUtils

+ (void)mergeVideo:(NSString *)videoPath andAudio:(NSString *)audioPath withCompletion:(ZYSExportVideoCompletion)completion {
    
    // video and audio resource
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
    
    // ouput file path
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *outputPath = [docPath stringByAppendingPathComponent:@"ScreenRecord.mp4"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:outputPath]) {
        if (![fm removeItemAtPath:outputPath error:nil]) {
            NSLog(@"remove old output file failed.");
        }
    }
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    
    
    // start time
    CMTime startTime = kCMTimeZero;
    
    // create composition
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    
    /// video collect
    // get video asset
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    // get video time range
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // create video channel
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // video collect channel
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    // add video collect channel data to a mutable channel
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:startTime error:nil];
    
    
    /// audio collect
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
    
    // use video time for audio time
    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    // create audio channel
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // audio collect channel
    AVAssetTrack *audioAssetTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    // add audio collect channel data to a mutable channel
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:startTime error:nil];
    
    // create output
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    
    // ouput type
    assetExport.outputFileType = AVFileTypeMPEG4;
    
    // output address
    assetExport.outputURL = outputURL;
    
    // optimization
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    // export
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        // delete original video and audio file

        if ([fm fileExistsAtPath:videoPath]) {
            if (![fm removeItemAtPath:videoPath error:nil]) {
                NSLog(@"remove video.mp4 failed.");
            }
        }
        
        if ([fm fileExistsAtPath:audioPath]) {
            if (![fm removeItemAtPath:audioPath error:nil]) {
                NSLog(@"remove audio.wav failed.");
            }
        }
        
        if (completion) {
            completion(outputPath);
        }
    }];
}

@end
