//
//  UIBarButtonItem+FlatUI.m
//  FlatUI
//
//  Created by Jack Flintermann on 5/8/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "UIBarButtonItem+FlatUI.h"
#import "UIImage+FlatUI.h"

@implementation UIBarButtonItem (FlatUI)

+ (void) configureFlatButtonsWithColor:(UIColor *) color
                      highlightedColor:(UIColor *)highlightedColor
                          cornerRadius:(CGFloat) cornerRadius {
    
    UIImage *backButtonPortraitImage = [UIImage backButtonImageWithColor:color
                                                              barMetrics:UIBarMetricsDefault
                                                            cornerRadius:cornerRadius];
    UIImage *highlightedBackButtonPortraitImage = [UIImage backButtonImageWithColor:highlightedColor
                                                                         barMetrics:UIBarMetricsDefault
                                                                       cornerRadius:cornerRadius];
    UIImage *backButtonLandscapeImage = [UIImage backButtonImageWithColor:color
                                                               barMetrics:UIBarMetricsLandscapePhone
                                                             cornerRadius:2];
    UIImage *highlightedBackButtonLandscapeImage = [UIImage backButtonImageWithColor:highlightedColor
                                                                          barMetrics:UIBarMetricsLandscapePhone
                                                                        cornerRadius:2];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonPortraitImage
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonLandscapeImage
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsLandscapePhone];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:highlightedBackButtonPortraitImage
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:highlightedBackButtonLandscapeImage
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsLandscapePhone];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(1.0f, 1.0f) forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(1.0f, 1.0f) forBarMetrics:UIBarMetricsLandscapePhone];
    
    UIImage *buttonImage = [UIImage imageWithColor:color cornerRadius:cornerRadius];
    [[UIBarButtonItem appearance] setBackgroundImage:buttonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
}

@end
