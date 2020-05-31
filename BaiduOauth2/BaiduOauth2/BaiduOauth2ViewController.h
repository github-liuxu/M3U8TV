//
//  BaiduOauth2ViewController.h
//  BaiduOauth2
//
//  Created by 刘东旭 on 2020/5/31.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BaiduOauth2ViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol BaiduOauth2ViewControllerDelegate <NSObject>

- (void)oauthLoginSuccess:(BaiduOauth2ViewController *)baiduOauthViewController info:(NSDictionary *)info;

- (void)oauthLoginFail:(BaiduOauth2ViewController *)baiduOauthViewController info:(NSDictionary *)info;

@end

@interface BaiduOauth2ViewController : UIViewController

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) NSString *url;

@end

NS_ASSUME_NONNULL_END
