//
//  MyPlayerViewController.m
//  电视直播
//
//  Created by 刘东旭 on 2018/12/21.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "ViewController.h"
#import "ListViewController.h"
#import "IJKMediaPlayer.h"
#import "Reachability.h"
#import "NvToast.h"
#import "Masonry.h"

//获取屏幕尺寸
#define SCREEN_WDITH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGTH [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
    
@property (nonatomic, strong) ListViewController *controller;
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) IJKFFMoviePlayerController *playerVC;

@property (nonatomic, assign) BOOL isAvPlayer;//是否使用avplayer
@property (nonatomic, strong) NSURL *avurl;

@property (nonatomic, strong) UIButton *jumpBtn;
@property (nonatomic, strong) UIWebView *webview;

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
        
        self.jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.jumpBtn.backgroundColor = UIColor.redColor;
        [self.jumpBtn setTitle:@"跳转" forState:UIControlStateNormal];
        [self.jumpBtn addTarget:self action:@selector(jumpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.jumpBtn];
        [self.jumpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-10);
            make.right.equalTo(self.view).offset(-10);
            make.width.offset(100);
            make.height.offset(60);
        }];
        
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

#pragma mark jumpBtnClick点击事件
- (void)jumpBtnClick:(UIButton *)sender{
    self.webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WDITH, SCREEN_HEIGTH-100)];
    
    [self.view addSubview:self.webview];
    
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
    
    UIView *bottomView = [[UIView alloc]init];
    [self.view addSubview:bottomView];
    bottomView.backgroundColor = UIColor.whiteColor;
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.webview.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.offset(100);
    }];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.backgroundColor = UIColor.redColor;
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(SCREEN_WDITH/4.0);
        make.height.offset(60);
        make.centerY.equalTo(bottomView);
    }];
    
    UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardBtn.backgroundColor = UIColor.redColor;
    [forwardBtn setTitle:@"前进" forState:UIControlStateNormal];
    [forwardBtn addTarget:self action:@selector(forwardBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:forwardBtn];
    [forwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backBtn.mas_right);
        make.width.offset(SCREEN_WDITH/4.0);
        make.height.offset(60);
        make.centerY.equalTo(bottomView);
    }];
    
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtn.backgroundColor = UIColor.redColor;
    [refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(refreshBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:refreshBtn];
    [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(forwardBtn.mas_right);
        make.width.offset(SCREEN_WDITH/4.0);
        make.height.offset(60);
        make.centerY.equalTo(bottomView);
    }];
    
    UIButton *homeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    homeBtn.backgroundColor = UIColor.redColor;
    [homeBtn setTitle:@"主页" forState:UIControlStateNormal];
    [homeBtn addTarget:self action:@selector(homeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:homeBtn];
    [homeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(refreshBtn.mas_right);
        make.width.offset(SCREEN_WDITH/4.0);
        make.height.offset(60);
        make.centerY.equalTo(bottomView);
    }];
}

#pragma mark backBtnClick点击事件{
- (void)backBtnClick:(UIButton *)sender{
    if (self.webview.canGoBack) {
        [self.webview goBack];
    }
}

#pragma mark forwardBtnClick点击事件{
- (void)forwardBtnClick:(UIButton *)sender{
    if (self.webview.canGoForward) {
        [self.webview goForward];
    }
}

#pragma mark refreshBtnClick点击事件{
- (void)refreshBtnClick:(UIButton *)sender{
    [self.webview reload];
}

#pragma mark homeBtnClick点击事件{
- (void)homeBtnClick:(UIButton *)sender{
    [self.webview loadHTMLString:@" " baseURL:nil];
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    [self.webview loadRequest:[NSURLRequest requestWithURL:url]];
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
    [self.playerVC stop];
    [self.playerVC.view removeFromSuperview];
    [self.playerVC shutdown];
    self.playerVC = nil;
    [self.player pause];
    self.player = nil;
    
    if (_isAvPlayer && ![url.absoluteString containsString:@"rtmp://"]) {
        self.player = [AVPlayer playerWithURL:url];
        self.showsPlaybackControls = YES;
        _isAvPlayer = YES;
        [self.controller setSwitchText:@"AV"];
    } else {
        _isAvPlayer = NO;
        // 拉流 URL
        self.playerVC = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:nil];
        [self.view addSubview:self.playerVC.view];
        [self.view insertSubview:self.playerVC.view belowSubview:self.controller.view];
        [self.playerVC prepareToPlay];
        [self.playerVC play];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
