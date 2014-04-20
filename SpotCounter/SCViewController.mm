//
//  SCViewController.m
//  SpotCounter
//
//  Created by Alcides Fonseca on 20/04/14.
//  Copyright (c) 2014 Alcides Fonseca. All rights reserved.
//

#include "opencv2/opencv.hpp"

#import "SCViewController.h"

@interface SCViewController ()

@end

@implementation SCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) processImage: (NSString *) file {
    NSLog(@"Processing file %@", file);
    cv::Mat img = cv::imread([file cStringUsingEncoding: NSUTF8StringEncoding]);
    cv::Mat hsv;
    cv::Mat rmask;
    cv::Mat ymask;
    cv::Mat gmask;
    
    cvtColor(img,hsv,cv::COLOR_BGR2HSV);
    cv::inRange(hsv, cv::Scalar(10, 100, 100), cv::Scalar(30, 255, 255), rmask);
    cv::inRange(hsv, cv::Scalar(0, 100, 100), cv::Scalar(10, 255, 255), ymask);
    cv::inRange(hsv, cv::Scalar(40, 100, 100), cv::Scalar(60, 255, 255), gmask);
    
    
    unsigned long red = [self processColor:img withMask:rmask];
    [[self redField] setStringValue:[NSString stringWithFormat:@"%lu",red]];

    unsigned long yellow = [self processColor:img withMask:ymask];
    [[self yellowField] setStringValue:[NSString stringWithFormat:@"%lu",yellow]];
    
    unsigned long green = [self processColor:img withMask:gmask];
    [[self greenField] setStringValue:[NSString stringWithFormat:@"%lu",green]];
    
}


- (unsigned long) processColor: (cv::Mat)img withMask: (cv::Mat)mask {
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::findContours(mask, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE);

    return contours.size();
}

@end
