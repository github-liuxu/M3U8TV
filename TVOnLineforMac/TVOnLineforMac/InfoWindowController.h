//
//  InfoWindowController.h
//  电视直播forMac
//
//  Created by 刘东旭 on 2019/2/21.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class InfoWindowController;

@protocol InfoWindowControllerDelegate <NSObject>

- (void)infoWindowController:(InfoWindowController *)infoWindowController name:(NSString *)name url:(NSString *)url;

@end

NS_ASSUME_NONNULL_BEGIN

@interface InfoWindowController : NSViewController

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) NSString *identify;

- (void)setName:(NSString *)name url:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
