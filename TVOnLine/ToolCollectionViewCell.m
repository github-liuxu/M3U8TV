//
//  ToolCollectionViewCell.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/6/7.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "ToolCollectionViewCell.h"

@implementation ToolCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

@end
