//
//  SCImageView.m
//  SpotCounter
//
//  Created by Alcides Fonseca on 20/04/14.
//  Copyright (c) 2014 Alcides Fonseca. All rights reserved.
//

#import "SCImageView.h"

@implementation SCImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    BOOL val = [super performDragOperation: sender];
    if (val) {
        NSPasteboard *pboard = [sender draggingPasteboard];
        NSString *plist = [pboard stringForType:
                           NSFilenamesPboardType];
        if (plist) {
            
            NSArray *files = [NSPropertyListSerialization
                              propertyListFromData:
                              [plist dataUsingEncoding: NSUTF8StringEncoding]
                              mutabilityOption:
                              NSPropertyListImmutable format: nil errorDescription: nil];
            if ([files count] == 1) {
                [[self vc] processImage: [files objectAtIndex: 0]];
            }
        }
    }
    return val;
}

@end
