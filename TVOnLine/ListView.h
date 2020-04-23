//
//  ListView.h
//  TVOnLine
//
//  Created by 刘东旭 on 2020/4/23.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ListViewDelegate <NSObject>

- (BOOL)isNeedResponse:(CGPoint)point;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ListView : UIView
@property (nonatomic, weak) id delegate;
@end

NS_ASSUME_NONNULL_END
