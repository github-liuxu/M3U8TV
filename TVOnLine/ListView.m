//
//  ListView.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/4/23.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "ListView.h"

@implementation ListView

//点击了此视图，此视图不相应，让该视图层下一层响应点击事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        if ([self.delegate isNeedResponse:point]) {
            return view;
        } else {
            return nil;
        }
    }
    return view;
}

@end
