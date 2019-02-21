//
//  InfoWindowController.m
//  电视直播forMac
//
//  Created by 刘东旭 on 2019/2/21.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import "InfoWindowController.h"

@interface InfoWindowController ()
@property (weak) IBOutlet NSTextField *nameField;
@property (weak) IBOutlet NSTextField *urlField;

@end

@implementation InfoWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)cancelClick:(id)sender {
    [self dismissController:sender];
}

- (IBAction)sureClick:(id)sender {
    
}

@end
