//
//  NvHttpRequest.h
//  电视直播
//
//  Created by ms20180425 on 2019/2/22.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvHttpRequest : NSObject

+ (NvHttpRequest *)sharedInstance;

@end

NS_ASSUME_NONNULL_END
