//
//  BaiduOauth2ViewController.m
//  BaiduOauth2
//
//  Created by 刘东旭 on 2020/5/31.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "BaiduOauth2ViewController.h"
@import WebKit;

@interface BaiduOauth2ViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation BaiduOauth2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    self.webView.navigationDelegate = self;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%@",webView.URL);
    NSString *callBackUrl = webView.URL.absoluteString;
    if ([callBackUrl containsString:@"https://openapi.baidu.com/oauth/2.0/login_success"]) {
        //https://openapi.baidu.com/oauth/2.0/login_success#expires_in=2592000&access_token=123.9cd464266bd2813d1348cb931b663092.Y5Uy8x-pSbYJ6WgupEe-H05_HhynrIdKV2FWqZS.Y-hueA&session_secret=&session_key=&scope=basic
        NSArray *datas = [[callBackUrl componentsSeparatedByString:@"#"].lastObject componentsSeparatedByString:@"&"];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [datas enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *array = [obj componentsSeparatedByString:@"="];
            [param setObject:array.lastObject forKey:array.firstObject];
        }];
        [self.delegate oauthLoginSuccess:self info:param];
    } else {
        [self.delegate oauthLoginFail:self info:nil];
    }
    
}

@end
