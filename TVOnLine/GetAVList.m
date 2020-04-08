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

@end
