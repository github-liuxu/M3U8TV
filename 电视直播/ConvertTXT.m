//
//  convertTxt.m
//  tt
//
//  Created by 刘东旭 on 2019/1/22.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import "ConvertTXT.h"

@implementation ConvertTXT

- (instancetype) initTextWith:(NSString *)filePath {
    if (self = [super init]) {
        self.array = [NSMutableArray array];
        NSError *error;
        NSString *resultStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"%@",resultStr);
        NSArray *array = [resultStr componentsSeparatedByString:@"\n"];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *arr = [obj componentsSeparatedByString:@","];
            if (arr.count == 2) {
                NSString *name = arr.firstObject;
                NSString *url = arr.lastObject;
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:name,@"name",url,@"url", nil];
                if (![name isEqualToString:@""] && ![url isEqualToString:@""]) {
                    [self.array addObject:dic];
                }
            }
        }];
    }
    return self;
}

@end
