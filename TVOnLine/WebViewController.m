//
//  WebViewController.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/5/22.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "WebViewController.h"
#import "NvToast.h"
@import WebKit;

@interface WebViewController ()<WKUIDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIButton *setButton;
@property (nonatomic, strong) NSString *jsUrlString;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
    self.webView.UIDelegate = self;
}

- (UIView *)leftNavigationBarItemView {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(0, 0, 30, 44);
    [self.backButton setTitle:@"<Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(leftNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return self.backButton;
}

- (UIView *)rightNavigationBarItemView {
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.frame = CGRectMake(0, 0, 30, 44);
    [self.rightButton setTitle:@"GetURL" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(rightNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return self.rightButton;
}

- (void)leftNavButtonClick:(UIButton *)button {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:true];
    }
}

- (void)rightNavButtonClick:(UIButton *)button {
    self.jsUrlString = nil;
    NSString* js = @"var videos = document.getElementsByTagName('video'); alert(videos[0].currentSrc)";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable any, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"%@",error.localizedFailureReason);
        }
        if (any != nil) {
            NSLog(@"%@",any);
        }
        NSLog(@"%@",self.jsUrlString);
        if (self.jsUrlString.length > 0) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.jsUrlString;
            [NvToast showInfoWithMessage:@"copy至剪切板"];
        }
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    if (message != nil) {
        self.jsUrlString = message;
        completionHandler();
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}
//返回直接支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskPortrait;
}
//返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationPortrait;
}


@end
