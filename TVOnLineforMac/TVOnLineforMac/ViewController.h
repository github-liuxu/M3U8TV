//
//  ViewController.h
//  电视直播forMac
//
//  Created by 刘东旭 on 2019/2/20.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVKit/AVKit.h>

@interface ViewController : NSViewController <NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet AVPlayerView *playerView;

@end

