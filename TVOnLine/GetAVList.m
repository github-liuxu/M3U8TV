//
//  GetAVList.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/4/9.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "GetAVList.h"
#import "HTMLKit.h"

@implementation GetAVList

+ (void)getAVList:(void(^)(NSString*))complate {
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

+ (void)getURL:(NSString *)uurl complate:(void(^)(NSString*))complate {
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:uurl]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Mobile Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    __weak typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //当被检索的字符串太大时，用block控制查找
        NSString *searchText = result;
        NSString *regex = @"liveLineUrl = \"([\\s\\S]*?)\";";
        NSError *err;
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&err];
        if (err) return;
        [regular enumerateMatchesInString:searchText options:NSMatchingReportCompletion range:NSMakeRange(0, searchText.length) usingBlock:^(NSTextCheckingResult * _Nullable result1, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            NSRange matchRange = result1.range;
            NSLog(@"range:%@",NSStringFromRange(matchRange));
            NSString *str = [searchText substringWithRange:matchRange];
            str = [str stringByReplacingOccurrencesOfString:@"liveLineUrl = \"" withString:@"https:"];
            str = [str stringByReplacingOccurrencesOfString:@"\";" withString:@""];
            *stop = true;
            complate(str);
        }];
    }];
    [task resume];
}

@end
