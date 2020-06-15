//
//  GetAVList.h
//  TVOnLine
//
//  Created by 刘东旭 on 2020/4/9.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetAVList : NSObject

+ (void)getAVList:(void(^)(NSString*))complate;
+ (void)getURL:(NSString *)uurl complate:(void(^)(NSString*))complate;

@end

NS_ASSUME_NONNULL_END
