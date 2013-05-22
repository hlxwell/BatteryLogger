//
//  ViewController.m
//  BatteryLogger
//
//  Created by Michael He on 2013/05/22.
//  Copyright (c) 2013年 MichaelHe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (atomic, assign) int remainedRequestCount;
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
    NSDate *startTime;
}

@synthesize remainedRequestCount = _remainedRequestCount;

- (void)viewDidLoad
{
    [super viewDidLoad];

    isStarted = false;
    self.remainedRequestCount = 0;

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //// Some style shit.
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
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)startOrStop:(id)sender
{
    isStarted ? [self stopTest] : [self startTest];
}

- (void)startTest
{
    self.remainedRequestCount = requestCountSlider.value;

    for (int i = 0; i < (int)concurrencySlider.value; i ++)
        [self startRequestThread];

    [self updateQueueIndicator];
    startTime = [NSDate date];

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
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startRequestThread
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    dispatch_queue_t queue = dispatch_queue_create("com.hlxwell.queue", NULL); // Create new thread?

    dispatch_async(queue, ^{
        while (self.remainedRequestCount > 0 && isStarted) {
            self.remainedRequestCount = self.remainedRequestCount - 1;

            // FIXME URL need to be validated.
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlTextField.text]];
            [request setShouldContinueWhenAppEntersBackground:YES];
            [request setCompletionBlock:^{
                [self updateQueueIndicator];
                NSLog(@"=========================== Complete %d", self.remainedRequestCount);
            }];
            [request setFailedBlock:^{
                [self updateQueueIndicator];
                NSLog(@"=========================== Failed %d", self.remainedRequestCount);
            }];
            [request startSynchronous];
        }
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)sliderValueChanged:(id)sender
{
    concurrencyCountLabel.text = [NSString stringWithFormat:@"%d", (int)[concurrencySlider value]];
    requestCountLabel.text = [NSString stringWithFormat:@"%d", (int)[requestCountSlider value]];
}

- (void)updateQueueIndicator
{
    [self updateFrequencyLabel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [queueIndicatorLabel setText:[NSString stringWithFormat:@"Remain: %d reqs", self.remainedRequestCount]];
    });
    if(self.remainedRequestCount == 0) [self stopTest];
}

// update the speed number
- (void)updateFrequencyLabel
{
    NSDate *endTime = [NSDate date];
    double ellapsedSeconds = [endTime timeIntervalSinceDate:startTime];
    int processedRequest = requestCountSlider.value - self.remainedRequestCount;
    float speed = processedRequest / ellapsedSeconds;
    if (isnan(speed)) speed = 0;

    dispatch_async(dispatch_get_main_queue(), ^{
        [centerLabel setText:[NSString stringWithFormat:@"%3.1f r/s", speed]];
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
