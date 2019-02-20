//
//  MyButton.m
//  电视直播forMac
//
//  Created by 刘东旭 on 2019/2/21.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import "MyButton.h"

@implementation MyButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [[NSColor yellowColor] set];
    NSRectFill(self.bounds); 
}

@end
