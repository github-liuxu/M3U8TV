//
//  FileListManager.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/5/1.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "FileListManager.h"
#import "LDXNetKit.h"

@implementation FileListManager

+ (void)GetFileList:(NSString *)listUrl complate:(void(^)(NSArray*))complateBlock {
    [LDXNetKit GETUrlString:listUrl param:nil complate:^(NSURLResponse *response, NSDictionary *result) {
        NSLog(@"%@", result);
        complateBlock(result[@"files"]);
    } failed:^(NSURLResponse *response, NSError *connectionError) {
        NSLog(@"%@", connectionError.localizedFailureReason);
        complateBlock(@[]);
    }];
}

+ (void)GetFileString:(NSString *)fileUrl complate:(void(^)(NSString*))complateBlock {
    [LDXNetKit GETUrlString:fileUrl param:nil result:^(NSURLResponse *response, NSString *result) {
        complateBlock(result);
    } failed:^(NSURLResponse *response, NSError *connectionError) {
        complateBlock(@"");
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
