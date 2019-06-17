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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setName:(NSString *)name url:(NSString *)urlString {
    self.nameField.stringValue = name;
    self.urlField.stringValue = urlString;
}

- (IBAction)cancelClick:(id)sender {
    [[NSApplication sharedApplication] stopModal];
    [[NSApplication sharedApplication].windows.lastObject close];
}

- (IBAction)sureClick:(id)sender {
    [[NSApplication sharedApplication] stopModal];
    if ([self.delegate respondsToSelector:@selector(infoWindowController:name:url:)]) {
        [self.delegate infoWindowController:self name:self.nameField.stringValue url:self.urlField.stringValue];
    }
    [[NSApplication sharedApplication].windows.lastObject close];
}

@end
