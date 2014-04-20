//
//  SCViewController.m
//  SpotCounter
//
//  Created by Alcides Fonseca on 20/04/14.
//  Copyright (c) 2014 Alcides Fonseca. All rights reserved.
//
#include "opencv2/opencv.hpp"

#import <Cocoa/Cocoa.h>
#import "SCViewController.h"


@interface SCViewController ()

@end

@implementation SCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    
    
    unsigned long red = [self processColor:rmask];
    [[self redField] setStringValue:[NSString stringWithFormat:@"%lu",red]];
    
    cv::Mat redImg = [self getColorOnlyImage:img withMask:rmask];
    self.redPath = [self saveImage: redImg withPrefix:@"red"];

    unsigned long yellow = [self processColor:ymask];
    [[self yellowField] setStringValue:[NSString stringWithFormat:@"%lu",yellow]];
    
    cv::Mat yellowImg = [self getColorOnlyImage:img withMask:ymask];
    self.yellowPath = [self saveImage: yellowImg withPrefix:@"yellow"];
    
    unsigned long green = [self processColor:gmask];
    [[self greenField] setStringValue:[NSString stringWithFormat:@"%lu",green]];
    
    cv::Mat greenImg = [self getColorOnlyImage:img withMask:gmask];
    self.greenPath = [self saveImage: greenImg withPrefix:@"green"];
    
}


- (NSString *)saveImage: (const cv::Mat&)img withPrefix: (NSString*)prefix {
    NSImage *nsi = [SCViewController imageWithCVMat:img];
    NSString* filePath = [self pathForTemporaryFileWithPrefix:prefix];
    [[nsi TIFFRepresentation] writeToFile:filePath atomically:NO];
    return filePath;
}


- (IBAction)viewRed:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:self.redPath];
}

- (IBAction)viewYellow:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:self.yellowPath];
}

- (IBAction)viewGreen:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:self.greenPath];
}


- (cv::Mat) getColorOnlyImage: (cv::Mat)img withMask:(cv::Mat)mask {
    cv::Mat final;
    cv::bitwise_and(img, img, final, mask);
    return final;
}

- (unsigned long) processColor: (cv::Mat)mask {
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::findContours(mask, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE);
    return contours.size();
}

+ (NSImage *)imageWithCVMat:(const cv::Mat&)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    NSImage* image = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [image addRepresentation:bitmapImageRep];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

+ (cv::Mat)cvMatWithImage:(NSImage *)image
{
    CGImage* cgi = [image CGImageForProposedRect:nullptr context:NULL hints:NULL];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgi);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), cgi);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

@end
