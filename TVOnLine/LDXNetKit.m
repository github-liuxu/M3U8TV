//
//  LDXNetKit.m
//  LDXNetKit
//
//  Created by 刘东旭 on 15/8/29.
//  Copyright (c) 2015年 刘东旭. All rights reserved.
//

#import "LDXNetKit.h"

@interface LDXNetKit()<NSURLSessionDelegate>

@end

@implementation LDXNetKit

+ (void)GETUrlString:(NSString *)urlString headers:(NSDictionary *)headers complate:(LDXComplateBlock)complateBlock failed:(LDXFailedBlock)failedBlock {
    [LDXNetKit GETUrlString:urlString headers:headers result:^(NSURLResponse *response, NSString *result) {
        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        complateBlock(response,resultDic);
    } failed:^(NSURLResponse *response, NSError *connectionError) {
        failedBlock(response, connectionError);
    }];
}

+ (void)GETUrlString:(NSString *)urlString headers:(NSDictionary *)headers result:(LDXResultBlock)resultBlock failed:(LDXFailedBlock)failedBlock {
    NSMutableURLRequest *request;
    NSURL *url = [NSURL URLWithString:urlString];
    request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    request.HTTPMethod = @"GET";
    if (headers) {
        request.allHTTPHeaderFields = headers;
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failedBlock(response, error);
        } else {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            resultBlock(response,result);
        }
    }];
    [task resume];
}
    
+ (void)POSTUrlString:(NSString *)urlString param:(NSDictionary *)param complate:(LDXComplateBlock)complateBlock failed:(LDXFailedBlock)failedBlock {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    request.HTTPMethod = @"POST";
    if (param) {
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
        request.HTTPBody = jsonData;
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failedBlock(response, error);
        } else {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            complateBlock(response,result);
        }
    }];
    [task resume];
}

+ (void)POSTUrlString:(NSString *)urlString param:(NSDictionary *)param result:(LDXResultBlock)resultBlock failed:(LDXFailedBlock)failedBlock {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    request.HTTPMethod = @"POST";
    if (param) {
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
        request.HTTPBody = jsonData;
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failedBlock(response, error);
        } else {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            resultBlock(response,result);
        }
    }];
    [task resume];
}

- (void)POSTUrlString:(NSString *)urlString param:(NSDictionary *)param mode:(Mode)mode isNetCache:(BOOL)isNetCache customizeServerTrustEvaluationResult:(LDXResultBlock)resultBlock failed:(LDXFailedBlock)failedBlock {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    request.HTTPMethod = @"POST";
    if (param) {
        NSData  *jsonData;
        if (mode == Text) {
            NSString *text = @"";
            for (NSString* str in param.allKeys) {
                id value = [param objectForKey:str];
                if ([value isKindOfClass:[NSString class]]) {
                    text = [text stringByAppendingFormat:@"%@=%@&",str,value];
                } else {
                    NSInteger tempNum = [value integerValue];
                    text = [text stringByAppendingFormat:@"%@=%ld&",str,(long)tempNum];
                }
            }
            text = [text substringToIndex:text.length-1];
            NSCharacterSet *encodeUrlSet = [NSCharacterSet URLQueryAllowedCharacterSet];
            NSString *encodeUrl = [text stringByAddingPercentEncodingWithAllowedCharacters:encodeUrlSet];
            jsonData = [encodeUrl dataUsingEncoding:NSUTF8StringEncoding];
        } else if (mode == Form) {
            jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
        }
        request.HTTPBody = jsonData;
    }
    NSURLSession *session = nil;
    if (isNetCache) {
        session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:NSOperationQueue.new];
    } else {
        session = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.ephemeralSessionConfiguration delegate:self delegateQueue:NSOperationQueue.new];
    }
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failedBlock(response, error);
        } else {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            resultBlock(response,result);
        }
    }];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    SecTrustRef sec = [challenge.protectionSpace serverTrust];
    NSURLCredential *cre = [NSURLCredential credentialForTrust:sec];
    completionHandler(NSURLSessionAuthChallengeUseCredential, cre);
}

@end
