//
//  GetAVList.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/4/9.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "GetAVList.h"
#import "HTMLKit.h"
@import UIKit;
@import WebKit;

@interface GetAVList () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, copy) void(^messageBlock)(NSString *urlString);

@end

@implementation GetAVList

- (void)getAVList:(void(^)(NSString*))complate {
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://ivi.bupt.edu.cn/"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __block NSString *r = @"";
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        HTMLParser *parser = [[HTMLParser alloc] initWithString:result];
        HTMLElement *element = [[HTMLElement alloc] initWithTagName:@"div"];
        NSArray *body = [parser parseFragmentWithContextElement:element];
        [body enumerateObjectsUsingBlock:^(HTMLNode*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj name] isEqualToString:@"div"]) {
                [obj enumerateChildNodesUsingBlock:^(HTMLNode * _Nonnull node, NSUInteger idx, BOOL * _Nonnull stop) {
                    [node enumerateChildElementsUsingBlock:^(HTMLElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *name = [element textContent];
                        if ([name componentsSeparatedByString:@"\n"].count > 1) {
                            name = [name componentsSeparatedByString:@"\n"][1];                            
                        }
                        [element enumerateChildElementsUsingBlock:^(HTMLElement * _Nonnull e, NSUInteger idx, BOOL * _Nonnull stop) {
                            [e.attributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                                if ([obj containsString:@"m3u8"]) {
                                    NSString *n = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                    r = [NSString stringWithFormat:@"%@%@,http://ivi.bupt.edu.cn%@\n",r,n,obj];
                                }
                            }];
                        }];
                    }];
                }];
            }
        }];
        complate(r);
    }] resume];
}

- (void)getURL:(NSString *)uurl complate:(void(^)(NSString*))complate {
    self.messageBlock = complate;
    self.message = @"";
    [self.webView removeFromSuperview];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(-100, -100, 50, 50)];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:uurl]]];
    [[[UIApplication sharedApplication] windows].firstObject addSubview:self.webView];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSString *js = @"var videos = document.getElementsByTagName('video');alert(videos[0].currentSrc);";
    __weak typeof(self)weakSelf = self;
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSLog(@"%@--%@",obj,error);
        weakSelf.messageBlock(weakSelf.message);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.webView.UIDelegate = nil;
            weakSelf.webView.navigationDelegate = nil;
            [weakSelf.webView removeFromSuperview];
            weakSelf.webView = nil;
            weakSelf.messageBlock = nil;
        });
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    self.message = message;
    completionHandler();
}

@end
