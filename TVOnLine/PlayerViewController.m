//
//  PlayerViewController.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/4/22.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ListViewController.h"
#if __has_include(<IJKMediaPlayer.h>)
#import "IJKMediaPlayer.h"
#endif
//#if !TARGET_OS_MACCATALYST
//#endif
#import "Reachability.h"
#import "NvToast.h"

@interface PlayerViewController ()

@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@property (nonatomic, strong) ListViewController *controller;
@property (nonatomic, strong) NSMutableArray *fileList;
#if __has_include(<IJKMediaPlayer.h>)
@property (nonatomic, strong) IJKFFMoviePlayerController *playerVC;
#endif
@property (nonatomic, assign) BOOL isAvPlayer;//是否使用avplayer
@property (nonatomic, strong) NSURL *avurl;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.playerViewController = [[AVPlayerViewController alloc] init];
    [self addChildViewController:self.playerViewController];
    [self.view addSubview:self.playerViewController.view];
    self.playerViewController.view.frame = self.view.bounds;
    [self.playerViewController didMoveToParentViewController:self];
    
    self.isAvPlayer = YES;
    self.controller = [[ListViewController alloc] initWithNibName:@"ListViewController" bundle:nil];
    self.controller.delegate = self;
    [self addChildViewController:self.controller];
    [self.controller didMoveToParentViewController:self];
    [self.view addSubview:self.controller.view];
    self.controller.view.frame = self.view.bounds;
    [self.controller.view bringSubviewToFront:self.view];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStateChange:) name:kReachabilityChangedNotification object:nil];
    // 创建Reachability
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    // 开始监控网络(一旦网络状态发生改变, 就会发出通知kReachabilityChangedNotification)
    [reachability startNotifier];
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
    
- (void)didSelectUrlString:(NSURL *)url {
    self.avurl = url;
#if __has_include(<IJKMediaPlayer.h>)
    [self.playerVC stop];
    [self.playerVC.view removeFromSuperview];
    [self.playerVC shutdown];
    self.playerVC = nil;
#endif
    [self.playerViewController.player pause];
    self.playerViewController.player = nil;
    
    if (_isAvPlayer && ![url.absoluteString containsString:@"rtmp://"] && ![url.absoluteString containsString:@"rtsp://"]) {
        if (self.playerViewController.player) {
            AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
            [self.playerViewController.player replaceCurrentItemWithPlayerItem:item];
        } else {
            self.playerViewController.player = [AVPlayer playerWithURL:url];
        }
        self.playerViewController.showsPlaybackControls = YES;
        _isAvPlayer = YES;
        [self.controller setSwitchText:@"AV"];
        [self.playerViewController.player play];
    } else {
        _isAvPlayer = NO;
        // 拉流 URL
#if __has_include(<IJKMediaPlayer.h>)
        self.playerVC = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:nil];
        [self.view addSubview:self.playerVC.view];
        [self.view insertSubview:self.playerVC.view belowSubview:self.controller.view];
        [self.playerVC prepareToPlay];
        [self.playerVC play];
#endif
        [self.controller setSwitchText:@"IJK"];
    }
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
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}
//返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft;
}

@end
