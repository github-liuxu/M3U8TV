//
//  AdvanceViewController.h
//  TVOnLine
//
//  Created by 刘东旭 on 2020/5/1.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceViewControllerDelegate <NSObject>

- (void)updateFromWeb;

@end

@interface AdvanceViewController : UIViewController

@property (nonatomic, weak) id delegate;

@end

NS_ASSUME_NONNULL_END
