//
//  ZYSRecordUtils.h
//  TestScreenRecorde
//
//  Created by zys on 2017/2/28.
//  Copyright © 2017年 XiYiChangXiang. All rights reserved.
//

/**
 *  Record utils(Merge video and audio)
 */

#import <Foundation/Foundation.h>

typedef void (^ZYSExportVideoCompletion)(NSString *exportVideoPath);

@interface ZYSRecorderUtils : NSObject

+ (void)mergeVideo:(NSString *)videoPath andAudio:(NSString *)audioPath withCompletion:(ZYSExportVideoCompletion)completion;

@end
