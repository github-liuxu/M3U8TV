//
//  MyPlayerViewController.m
//  电视直播
//
//  Created by 刘东旭 on 2018/12/21.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "ViewController.h"
#import "ListViewController.h"
//#import "IJKMediaPlayer.h"
#import "Reachability.h"
#import "NvToast.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
    
@property (nonatomic, strong) ListViewController *controller;
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) IJKFFMoviePlayerController *playerVC;

@property (nonatomic, assign) BOOL isAvPlayer;//是否使用avplayer
@property (nonatomic, strong) NSURL *avurl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStateChange:) name:kReachabilityChangedNotification object:nil];
    // 创建Reachability
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    // 开始监控网络(一旦网络状态发生改变, 就会发出通知kReachabilityChangedNotification)
    [reachability startNotifier];
    
    self.isAvPlayer = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.controller = [[ListViewController alloc] init];
        self.controller.delegate = self;
        self.controller.rect = CGRectMake(self.view.bounds.size.width - 30, 0, 300, self.view.bounds.size.height);
        [self addChildViewController:self.controller];
        [self.controller didMoveToParentViewController:self];
        [self.view addSubview:self.controller.view];
        [self.controller.view bringSubviewToFront:self.view];
        
        [self.view addSubview:self.tableView];
        self.tableView.hidden = YES;
        self.tableView.backgroundColor = [UIColor clearColor];
        
        //获取当前网络状态
        if ([reachability currentReachabilityStatus] == ReachableViaWiFi) {
            [NvToast showInfoWithMessage:@"当前使用Wi-Fi网络"];
        } else if ([reachability currentReachabilityStatus] == ReachableViaWWAN) {
            [NvToast showInfoWithMessage:@"当前使用蜂窝网络"];
        } else {
            [NvToast showInfoWithMessage:@"没有网络"];
        }
    });

}

- (void)networkStateChange:(NSNotification *)notification {
    Reachability *reach = [notification object];
    if([reach isKindOfClass:[Reachability class]]){
        NetworkStatus status = [reach currentReachabilityStatus];
        if (status == ReachableViaWiFi) {
            [NvToast showInfoWithMessage:@"当前使用Wi-Fi网络"];
        } else if (status == ReachableViaWWAN) {
            [NvToast showInfoWithMessage:@"当前使用蜂窝网络"];
        } else {
            [NvToast showInfoWithMessage:@"没有网络"];
        }
        
    }
}
    
- (void)shareFilePath:(NSString *)filePath {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:filePath]] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:NULL];
}
    
- (void)didSelectUrlString:(NSURL *)url {
    self.avurl = url;
//    [self.playerVC stop];
//    [self.playerVC.view removeFromSuperview];
//    [self.playerVC shutdown];
//    self.playerVC = nil;
    [self.player pause];
    self.player = nil;
    
    if (_isAvPlayer && ![url.absoluteString containsString:@"rtmp://"] && ![url.absoluteString containsString:@"rtsp://"]) {
        self.player = [AVPlayer playerWithURL:url];
        self.showsPlaybackControls = YES;
        _isAvPlayer = YES;
        [self.controller setSwitchText:@"AV"];
        [self.player play];
    } else {
        _isAvPlayer = NO;
        // 拉流 URL
//        self.playerVC = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:nil];
//        [self.view addSubview:self.playerVC.view];
//        [self.view insertSubview:self.playerVC.view belowSubview:self.controller.view];
//        [self.playerVC prepareToPlay];
//        [self.playerVC play];
        [self.controller setSwitchText:@"IJK"];
    }
}
    
- (void)buttonClick:(UIButton *)button {
    if (self.controller.view.frame.origin.x < self.view.bounds.size.width - 30) {
        [UIView animateWithDuration:0.3 animations:^{
            button.alpha = 0.3;
            self.controller.view.frame = CGRectMake(self.view.bounds.size.width - 30, 0, 300, self.view.bounds.size.height);
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            button.alpha = 0.8;
            self.controller.view.frame = CGRectMake(self.view.bounds.size.width - 300, 0, 300, self.view.bounds.size.height);
        }];
    }
}

- (void)listFilePath:(UIButton *)button {
    NSString *docpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    self.fileList = [[NSMutableArray alloc] init];
    [[fm contentsOfDirectoryAtPath:docpath error:nil] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isEqualToString:@".DS_Store"] && ![obj isEqualToString:@"Inbox"]) {
            [self.fileList addObject:obj];
        }
    }];
    
    self.tableView.hidden = !self.tableView.hidden;
    [self.tableView reloadData];
}

- (void)switchPlayer:(UIButton *)button {
    if (_isAvPlayer) {
        _isAvPlayer = NO;
        [button setTitle:@"IJK" forState:UIControlStateNormal];
    } else {
        _isAvPlayer = YES;
        [button setTitle:@"AV" forState:UIControlStateNormal];
    }
    if (self.avurl) {
        [self didSelectUrlString:self.avurl];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}
//返回直接支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}
//返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellFileList" forIndexPath:indexPath];
    cell.textLabel.text = self.fileList[indexPath.row];
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

#pragma Mark 左滑按钮 iOS8以上
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    //添加一个删除按钮
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        //先删数据 再删UI
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *docpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        [fm removeItemAtPath:[docpath stringByAppendingPathComponent:self.fileList[indexPath.row]] error:nil];
        [self.fileList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    return @[deleteAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fileString = self.fileList[indexPath.row];
    self.tableView.hidden = YES;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [path stringByAppendingPathComponent:fileString];
    [self.controller setFilePath:filePath];
}

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 150)/2, 40, 150, self.view.bounds.size.height - 120) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellFileList"];
        
    }
    return _tableView;
}

@end
