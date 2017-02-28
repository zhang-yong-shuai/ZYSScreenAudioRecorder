//
//  ZYSAudioRecorder.h
//  TestScreenRecorde
//
//  Created by zys on 2017/2/28.
//  Copyright © 2017年 XiYiChangXiang. All rights reserved.
//

/**
 *  Audio recorder
 */

#import <Foundation/Foundation.h>

@interface ZYSAudioRecorder : NSObject

@property (nonatomic, copy, readonly) NSString *audioPath;

- (void)startRecord;
- (void)pauseRecord;
- (void)stopRecord;
- (void)deleteRecord;

@end
