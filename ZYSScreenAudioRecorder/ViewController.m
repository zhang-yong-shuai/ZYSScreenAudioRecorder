//
//  ViewController.m
//  ZYSScreenAudioRecorder
//
//  Created by zys on 2017/2/28.
//  Copyright © 2017年 XiYiChangXiang. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "ViewController.h"
#import "ZYSScreenAudioRecorder.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *recordingView;
@property (nonatomic, strong) ZYSScreenAudioRecorder *recorder;

@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - event response
- (IBAction)changeColorBtnClicked:(id)sender {
    NSArray *colors = @[[UIColor greenColor],
                        [UIColor cyanColor],
                        [UIColor brownColor],
                        [UIColor blueColor],
                        [UIColor orangeColor],
                        [UIColor redColor]];
    static NSInteger index = 0;
    if (index > colors.count - 1) {
        index = 0;
    }
    self.recordingView.backgroundColor = colors[index++];
}

- (IBAction)startRecordBtnClicked:(id)sender {
    [self.recorder startRecording];
}

- (IBAction)pauseRecordBtnClicked:(id)sender {
    [self.recorder pauseRecording];
}

- (IBAction)stopRecordBtnClicked:(id)sender {
    [self.recorder stopRecordingWithHandler:^(NSString *videoPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
            [player.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
            [player.moviePlayer prepareToPlay];
            [player.moviePlayer play];
            [self presentMoviePlayerViewControllerAnimated:player];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        });
    }];
}

// movie play finished.
- (void)movieFinishedCallback:(NSNotification *)notifycation{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self dismissMoviePlayerViewControllerAnimated];
}

#pragma mark - Getters
- (ZYSScreenAudioRecorder *)recorder {
    if (!_recorder) {
        _recorder = [[ZYSScreenAudioRecorder alloc] initWithRecordView:self.recordingView];
    }
    
    return _recorder;
}


@end
