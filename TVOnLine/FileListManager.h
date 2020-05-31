//
//  FileListManager.h
//  TVOnLine
//
//  Created by 刘东旭 on 2020/5/1.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QTTopLevel.h"
#import "FileInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface FileListManager : NSObject

+ (void)GetFileList:(NSString *)listUrl cls:(Class)cls complate:(void(^)(id obj))complateBlock;
+ (void)GetFileString:(NSString *)fileUrl complate:(void(^)(NSString* string))complateBlock;
+ (void)PostFileString:(NSString *)fileUrl param:(NSDictionary *)param complate:(void(^)(NSString* string))complateBlock;

@end

NS_ASSUME_NONNULL_END
