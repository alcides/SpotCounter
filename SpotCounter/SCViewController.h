//
//  SCViewController.h
//  SpotCounter
//
//  Created by Alcides Fonseca on 20/04/14.
//  Copyright (c) 2014 Alcides Fonseca. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SCViewController : NSViewController

@property (weak) IBOutlet NSTextField *redField;
@property (weak) IBOutlet NSTextField *yellowField;
@property (weak) IBOutlet NSTextFieldCell *greenField;
@property (weak) IBOutlet NSImageView *image;
@property NSString* redPath;
@property NSString* yellowPath;
@property NSString* greenPath;


- (void) processImage: (NSString *) file;

- (IBAction)viewRed:(id)sender;
- (IBAction)viewYellow:(id)sender;
- (IBAction)viewGreen:(id)sender;

@end
