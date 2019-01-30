//
//  ListViewController.h
//  电视直播
//
//  Created by 刘东旭 on 2018/12/21.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ViewContrllerDelegate <NSObject>

- (void)didSelectUrlString:(NSURL *)url;
    
- (void)buttonClick:(UIButton *)button;
    
- (void)shareFilePath:(NSString *)filePath;

- (void)listFilePath:(UIButton *)button;

- (void)switchPlayer:(UIButton *)button;

@end

@interface ListViewController : UIViewController
    
@property (weak, nonatomic) id delegate;

@property (assign, nonatomic) CGRect rect;

@property (strong, nonatomic) NSString *filePath;

- (void)setSwitchText:(NSString *)text;

@end

