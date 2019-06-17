//
//  convertTxt.h
//  tt
//
//  Created by 刘东旭 on 2019/1/22.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConvertTXT : NSObject

- (instancetype) initTextWith:(NSString *)filePath;

@property (nonatomic, strong) NSMutableArray *array;

@end

NS_ASSUME_NONNULL_END
