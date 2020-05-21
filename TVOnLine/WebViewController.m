//
//  WebViewController.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/5/22.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "WebViewController.h"
@import WebKit;

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

@end
