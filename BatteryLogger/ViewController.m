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
    IBOutlet UILabel *queueIndicatorLabel;
    IBOutlet UITextView *logLabel;

    ASINetworkQueue *queue;
    BOOL isStarted;
    NSTimer *requestTimer;
    float lastBattery;
    NSString *logMsg;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Label
    centerLabel.font = [UIFont boldFlatFontOfSize:50];
    queueIndicatorLabel.font = [UIFont boldFlatFontOfSize:30];
    [queueIndicatorLabel setTextColor:[UIColor cloudsColor]];
    
    // Log label
    [logLabel setText:@""];
    //[logLabel setAllowsEditingTextAttributes:false];
    logLabel.font = [UIFont boldFlatFontOfSize:10];
    [logLabel setTextColor:[UIColor blackColor]];

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
    
    // Variables
    lastBattery = -2;
    logMsg = @"";
    
    // Enable battery monitoring
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:true];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)startOrStop:(id)sender
{
    if (isStarted) {
        // cleanup queue
        queue = [[ASINetworkQueue alloc] init];
        queue.maxConcurrentOperationCount = 5;

        [queueIndicatorLabel setText:@"0"];

        [self stopTimer];
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
    } else { // START
        [self startTimer];
        [logLabel setText:@""];
        logMsg = @"";
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
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://geo.skillupjapan.net/index.json"]];
    [request setShouldContinueWhenAppEntersBackground:YES];
    
    [request setCompletionBlock:^{
        if (lastBattery != [[UIDevice currentDevice] batteryLevel]) {
            lastBattery = [[UIDevice currentDevice] batteryLevel];
            [self updateQueueIndicator];
            NSLog(@"%@, %f", [NSDate date], lastBattery);
            [self updateLog];
        }
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

- (void)updateLog
{
    logMsg = [logMsg stringByAppendingString:[NSString stringWithFormat:@"%@, %f\n", [NSDate date], lastBattery]];
    [logLabel setText:[NSString stringWithFormat:@"%@", logMsg]];
    
    NSUInteger length = logLabel.text.length;
    logLabel.selectedRange = NSMakeRange(0, length);
}

- (void)updateQueueIndicator
{
    [queueIndicatorLabel setText:[NSString stringWithFormat:@"%d", [queue operationCount]]];
}

- (void)updateFrequencyLabel
{
    [centerLabel setText:[NSString stringWithFormat:@"%3.0f r/m", slider.value]];
}

@end
