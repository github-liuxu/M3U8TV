//
//  NvHttpRequest.m
//  电视直播
//
//  Created by ms20180425 on 2019/2/22.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import "NvHttpRequest.h"

@interface NvHttpRequest()

@end

static NvHttpRequest *sharedInstance = nil;
static AFHTTPSessionManager *httpSessionManager;
static AFNetworkReachabilityManager *networkManager;
@implementation NvHttpRequest

+ (NvHttpRequest *)sharedInstance{
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[NvHttpRequest alloc] init];
        networkManager = [AFNetworkReachabilityManager sharedManager];
    });
    
    return sharedInstance;
}

@end
