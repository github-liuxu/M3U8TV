//
//  FileListManager.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/5/1.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "FileListManager.h"
#import "LDXNetKit.h"
#import "YYModel.h"

@implementation FileListManager

+ (void)GetFileList:(NSString *)listUrl cls:(Class)cls complate:(void(^)(id obj))complateBlock {
    //文件列表
    [LDXNetKit GETUrlString:listUrl headers:@{@"User-Agent":@"pan.baidu.com"} complate:^(NSURLResponse *response, NSDictionary *result) {
        NSObject * topLevel = [cls yy_modelWithDictionary:result];
        complateBlock(topLevel);
    } failed:^(NSURLResponse *response, NSError *connectionError) {
        complateBlock(nil);
    }];
}

+ (void)GetFileString:(NSString *)fileUrl complate:(void(^)(NSString*))complateBlock {
    [LDXNetKit GETUrlString:fileUrl headers:@{@"User-Agent":@"pan.baidu.com"} result:^(NSURLResponse *response, NSString *result) {
        complateBlock(result);
    } failed:^(NSURLResponse *response, NSError *connectionError) {
        complateBlock(nil);
    }];
}

+ (void)PostFileString:(NSString *)fileUrl param:(NSDictionary *)param complate:(void(^)(NSString* string))complateBlock {
    [LDXNetKit POSTUrlString:fileUrl param:param result:^(NSURLResponse *response, NSString *result) {
        complateBlock(result);
    } failed:^(NSURLResponse *response, NSError *connectionError) {
        complateBlock(connectionError.localizedFailureReason);
    }];
}

@end
