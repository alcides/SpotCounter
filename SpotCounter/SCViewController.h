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


- (void) processImage: (NSString *) file;

@end
