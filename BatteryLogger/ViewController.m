//
//  ViewController.m
//  BatteryLogger
//
//  Created by Michael He on 2013/05/22.
//  Copyright (c) 2013年 MichaelHe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    IBOutlet FUIButton *startButton;
    IBOutlet UILabel *centerLabel;
    IBOutlet UISlider *slider;
    IBOutlet UITextView *logView;

    ASINetworkQueue *queue;
    BOOL isStarted;
    NSTimer *requestTimer;
    NSMutableString *logText;
    float lastBattery;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    logText = [NSMutableString string];
    // Label
    centerLabel.font = [UIFont boldFlatFontOfSize:50];

    // Slider
    [slider configureFlatSliderWithTrackColor:[UIColor silverColor]
                                progressColor:[UIColor alizarinColor]
                                   thumbColor:[UIColor pomegranateColor]];

    // Start button
    startButton.buttonColor = [UIColor turquoiseColor];
    startButton.shadowColor = [UIColor greenSeaColor];
    startButton.shadowHeight = 3.0f;
    startButton.cornerRadius = 6.0f;
    startButton.titleLabel.font = [UIFont boldFlatFontOfSize:50];
    [startButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    requestTimer = nil;
    isStarted = false;
    
    // Queue
    queue = [[ASINetworkQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    lastBattery = -2;
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)startOrStop:(id)sender
{
    if (isStarted) {
        // cleanup queue
        queue = [[ASINetworkQueue alloc] init];
        queue.maxConcurrentOperationCount = 5;

        [self stopTimer];
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
    } else { // START
        [self startTimer];
        [startButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (void)stopTimer
{
    if (requestTimer) {
        [requestTimer invalidate];
        requestTimer = nil;
    }

    isStarted = NO;
}

- (void)startTimer
{
    [self stopTimer];
    
    if (slider.value > 0) {
        float frequency = 60.0 / slider.value;
        requestTimer = [NSTimer scheduledTimerWithTimeInterval:frequency
                                                        target:self selector:@selector(sendRequest)
                                                      userInfo:nil repeats:YES];
    }

    [self updateFrequencyLabel];
    isStarted = YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)sendRequest
{
    // http://primebook.skillupjapan.net/m/bookstore.json
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://www.microsoft.co.jp"]];
    
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setCompletionBlock:^{
        [self updateQueueIndicator];
        NSLog(@"=-=-=%d - %d", request.responseStatusCode, request.responseData.length);
        NSLog(@"=========================== Complete %d Battery %f", [queue operationCount], [[UIDevice currentDevice] batteryLevel]);
    }];
    [request setFailedBlock:^{
        [self updateQueueIndicator];
        NSLog(@"=========================== Failed %d Battery %f", [queue operationCount], [[UIDevice currentDevice] batteryLevel]);
    }];
    [queue addOperation:request];
    [queue setSuspended:NO];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)sliderValueChanged:(id)sender
{
    if (isStarted) [self startTimer];
    [self updateFrequencyLabel];
}

- (void)updateQueueIndicator
{
    if (lastBattery != [[UIDevice currentDevice] batteryLevel]) {
        [logText appendFormat:@"%@, %f\n", [NSDate date], [[UIDevice currentDevice] batteryLevel]];
        [logView setText:logText];
        logView.selectedRange = NSMakeRange(0, logText.length);
        lastBattery = [[UIDevice currentDevice] batteryLevel];
    }
}

- (void)updateFrequencyLabel
{
    [centerLabel setText:[NSString stringWithFormat:@"%3.0f r/m", slider.value]];
}

@end
