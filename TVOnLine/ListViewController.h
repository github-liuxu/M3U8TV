//
//  ListViewController.h
//  TVOnLine
//
//  Created by 刘东旭 on 2020/4/22.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ViewContrllerDelegate <NSObject>

- (void)didSelectUrlString:(NSURL *)url;
    
- (void)buttonClick:(UIButton *)button;
    
- (void)shareFilePath:(NSString *)filePath;

- (void)listFilePath:(UIButton *)button;

- (void)switchPlayer:(UIButton *)button;

@end

@interface ListViewController : UIViewController

@property (weak, nonatomic) id delegate;

@property (strong, nonatomic) NSString *filePath;

- (void)setSwitchText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
