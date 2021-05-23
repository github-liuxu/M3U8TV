//
//  HuYa.m
//  TVOnLine
//
//  Created by 刘东旭 on 2021/5/16.
//  Copyright © 2021 刘东旭. All rights reserved.
//

#import "HuYa.h"
#import "LDXNetKit.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HuYa

- (NSDictionary *)getRealUrl:(NSString *)rid {
    NSString *roomUrl = [@"https://m.huya.com/" stringByAppendingString:rid];
    NSDictionary *header = @{
        @"Content-Type": @"application/x-www-form-urlencoded",
        @"User-Agent": @"Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Mobile Safari/537.36 "
    };
    __block NSDictionary *real_url = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [LDXNetKit GETUrlString:roomUrl headers:header result:^(NSURLResponse *response, NSString *result) {
//        NSLog(@"%@",result);
        NSString *resultUrl = @"";
        NSString *searchText = result;
        NSError *error = NULL;
        NSString *regexstr = @"liveLineUrl = \"([\\s\\S]*?)\"";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexstr options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *rt = [regex firstMatchInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
        
        if (rt) {
            resultUrl = [[[searchText substringWithRange:rt.range] stringByReplacingOccurrencesOfString:@"liveLineUrl = " withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            resultUrl = [self decodebase64String:resultUrl];
            if (resultUrl) {
                if ([resultUrl containsString:@"replay"]) {
                    real_url = @{
                        @"replay": [@"https:" stringByAppendingString:resultUrl]
                    };
                } else {
                    NSString *s_url = [self live:resultUrl];
                    NSString *b_url = [self live:[resultUrl stringByReplacingOccurrencesOfString:@"_2000" withString:@""]];
                    real_url = @{
                        @"2000p": [@"https:" stringByAppendingString:s_url],
                        @"tx": [@"https:" stringByAppendingString:b_url],
                        @"bd": [@"https:" stringByAppendingString:[b_url stringByReplacingOccurrencesOfString:@"tx.hls.huya.com" withString:@"bd.hls.huya.com"]],
                        @"migu-bd": [@"https:" stringByAppendingString:[b_url stringByReplacingOccurrencesOfString:@"tx.hls.huya.com" withString:@"migu-bd.hls.huya.com"]]
                    };
                }
            }
        }
        dispatch_semaphore_signal(sem);
    } failed:^(NSURLResponse *response, NSError *connectionError) {
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return real_url;
}

- (NSString *)live:(NSString *)url {
    NSArray *array = [url componentsSeparatedByString:@"?"];
    NSString *i = [array firstObject];
    NSString *b = [array lastObject];
    NSArray *r = [i componentsSeparatedByString:@"/"];
    NSString *s = r.lastObject;
    s = [[s stringByReplacingOccurrencesOfString:@".m3u8" withString:@""] stringByReplacingOccurrencesOfString:@".flv" withString:@""];
    NSArray *c = [b componentsSeparatedByString:@"&"];
    NSMutableArray *c1 = NSMutableArray.array;
    __block NSString *s2 = @"";
    [c enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isEqualToString:@""]) {
            if (idx < 3) {
                [c1 addObject:obj];
            } else if (idx == 3) {
                s2 = obj;
            } else {
                s2 = [NSString stringWithFormat:@"%@&%@",s2,obj];
            }
        }
    }];
    [c1 addObject:s2];
    c = [c1 copy];
    NSMutableDictionary *n = [NSMutableDictionary dictionary];
    [c enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *cc = [obj componentsSeparatedByString:@"="];
        [n setObject:cc.lastObject forKey:cc.firstObject];
    }];
    NSString *fm = [self decodeFromPercentEscapeString:n[@"fm"]];
    NSString *u = [self decodebase64String:fm];
    NSString *p = [u componentsSeparatedByString:@"_"].firstObject;
    NSInteger pp = [[NSDate date] timeIntervalSince1970] * 10000000;
    NSString *f = [NSString stringWithFormat:@"%lld",pp];
    NSString *ll = n[@"wsTime"];
    NSString *t = @"0";
    NSString *h = [NSString stringWithFormat:@"%@_%@_%@_%@_%@",p,t,s,f,ll];
    NSString *m = [self md5To32bit:h];
    NSString *y = c.lastObject;
    NSString *urll = [NSString stringWithFormat:@"%@?wsSecret=%@&wsTime=%@&u=%@&seqid=%@&%@",i, m, ll, t, f, y];
    return urll;
}

- (NSString *)md5To32bit:(NSString *)str {
  const char *cStr = [str UTF8String];
  unsigned char digest[CC_MD5_DIGEST_LENGTH];
  CC_MD5( cStr, strlen(cStr),digest );
  NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [result appendFormat:@"%02x", digest[i]];
  return result;
}

- (NSString *)decodeFromPercentEscapeString:(NSString *)input {
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,[outputStr length])];
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)decodebase64String:(NSString *)str {
    NSData *sData = [[NSData alloc]initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSString alloc]initWithData:sData encoding:NSUTF8StringEncoding];
}

@end
