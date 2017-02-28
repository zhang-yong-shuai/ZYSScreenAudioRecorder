# ZYSScreenAudioRecorder
ZYSScreenAudioRecorder can record a view of screen with audio, and generate a mp4 file.
####How to use ZYSScreenAudioRecorder?
You can use ZYSScreenAudioRecorder like this:
```
// state a recorder member variable
@property (nonatomic, strong) ZYSScreenAudioRecorder *recorder;

#pragma mark - Getters
- (ZYSScreenAudioRecorder *)recorder {
    if (!_recorder) {
        _recorder = [[ZYSScreenAudioRecorder alloc] initWithRecordView:self.recordingView];
    }
    
    return _recorder;
}

#pragma mark - event response
- (IBAction)startRecordBtnClicked:(id)sender {
    // start recording
    [self.recorder startRecording];
}

- (IBAction)pauseRecordBtnClicked:(id)sender {
    // pause recording
    [self.recorder pauseRecording];
}

- (IBAction)stopRecordBtnClicked:(id)sender {
    // stop recording, and handle the mp4 file
    [self.recorder stopRecordingWithHandler:^(NSString *videoPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Now you can handle the mp4 file, e.g. to play...
            MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
            [player.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
            [player.moviePlayer prepareToPlay];
            [player.moviePlayer play];
            [self presentMoviePlayerViewControllerAnimated:player];
        });
    }];
}

```
