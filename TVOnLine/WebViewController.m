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
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

- (UIView *)leftNavigationBarItemView {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(0, 0, 30, 44);
    [self.backButton setTitle:@"<Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(leftNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return self.backButton;
}

- (void)leftNavButtonClick:(UIButton *)button {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:true];
    }
}

@end
