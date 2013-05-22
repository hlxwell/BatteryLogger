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
    IBOutlet UITextField *urlTextField;
    
    IBOutlet UISlider *concurrencySlider;
    IBOutlet UISlider *requestCountSlider;
    
    IBOutlet UILabel *concurrencyCountLabel;
    IBOutlet UILabel *requestCountLabel;

    IBOutlet UILabel *centerLabel;
    IBOutlet UILabel *queueIndicatorLabel;
    
    IBOutlet FUIButton *startButton;

    BOOL isStarted;
    ASINetworkQueue *queue;
    NSDate *startTime;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Label
    centerLabel.font = [UIFont boldFlatFontOfSize:50];
    queueIndicatorLabel.font = [UIFont boldFlatFontOfSize:30];
    [queueIndicatorLabel setTextColor:[UIColor cloudsColor]];

    // Slider
    [concurrencySlider configureFlatSliderWithTrackColor:[UIColor silverColor]
                                           progressColor:[UIColor alizarinColor]
                                              thumbColor:[UIColor pomegranateColor]];

    [requestCountSlider configureFlatSliderWithTrackColor:[UIColor silverColor]
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
    isStarted = false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)startOrStop:(id)sender
{
    isStarted ? [self stopTest] : [self startTest];
}

- (void)startTest
{
    queue = [[ASINetworkQueue alloc] init];
    queue.maxConcurrentOperationCount = concurrencySlider.value;
    [queue setSuspended:YES];

    // send request to queue.
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        for (int i = 0; i < requestCountSlider.value; i ++)
            [self sendRequest];

        [self updateQueueIndicator];
        [queue setSuspended:NO];
        startTime = [NSDate date];
    });

    [concurrencySlider setEnabled:NO];
    [requestCountSlider setEnabled:NO];
    isStarted = YES;
    [startButton setTitle:@"Stop" forState:UIControlStateNormal];
}

- (void)stopTest
{
    // cleanup queue
    [queueIndicatorLabel setText:@"Remain: 0 reqs"];

    [concurrencySlider setEnabled:YES];
    [requestCountSlider setEnabled:YES];
    isStarted = NO;

    [queue setSuspended:YES];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)sendRequest
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlTextField.text]];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setCompletionBlock:^{
        NSLog(@"=========================== Complete %d", [queue operationCount]);
        [self updateQueueIndicator];
    }];
    [request setFailedBlock:^{
        NSLog(@"=========================== Failed %d", [queue operationCount]);
        [self updateQueueIndicator];
    }];
    [queue addOperation:request];
    [self updateQueueIndicator];
    NSLog(@"=========================== Added request %d", [queue operationCount]);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)sliderValueChanged:(id)sender
{
    concurrencyCountLabel.text = [NSString stringWithFormat:@"%d", (int)[concurrencySlider value]];
    requestCountLabel.text = [NSString stringWithFormat:@"%d", (int)[requestCountSlider value]];
}

- (void)updateQueueIndicator
{
    NSLog(@"=========================== Updating queue count %d", [queue operationCount]);
    [self updateFrequencyLabel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [queueIndicatorLabel setText:[NSString stringWithFormat:@"Remain: %d reqs", [queue operationCount]]];
    });
    
    if ([queue operationCount] == 0) [self stopTest];
}

// update the speed number
- (void)updateFrequencyLabel
{
    NSLog(@"=========================== Updating frequency %d", [queue operationCount]);
    NSDate *endTime = [NSDate date];
    double ellapsedSeconds = [endTime timeIntervalSinceDate:startTime];
    int processedRequest = requestCountSlider.value - [queue operationCount];
    float speed = processedRequest / ellapsedSeconds;

    dispatch_async(dispatch_get_main_queue(), ^{
        [centerLabel setText:[NSString stringWithFormat:@"%3.1f r/s", speed]];
    });    
}

@end
