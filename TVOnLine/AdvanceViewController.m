//
//  AdvanceViewController.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/5/1.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "AdvanceViewController.h"
#import "FileListManager.h"

@interface AdvanceViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndictator;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation AdvanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.queue = dispatch_queue_create("NvUploadRequest", DISPATCH_QUEUE_CONCURRENT);
}

- (IBAction)tapClick:(UITapGestureRecognizer *)sender {
    [self.textField resignFirstResponder];
    [self.textView resignFirstResponder];
}

- (IBAction)downloadClick:(UIButton *)sender {
    self.activityIndictator.hidden = false;
    [self.activityIndictator startAnimating];
    [self downloadTvFiles:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndictator stopAnimating];
        });
    }];
}

- (IBAction)uploadClick:(UIButton *)sender {
    self.activityIndictator.hidden = false;
    [self.activityIndictator startAnimating];
    [self uploadTvFiles:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndictator stopAnimating];
        });
    }];
}

- (IBAction)closeClick:(id)sender {
    [self.activityIndictator removeFromSuperview];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)downloadTvFiles:(void(^)(void))block {
    NSString *fpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    __weak typeof(self)weakSelf = self;
    NSString *host = self.textField.text;
    [FileListManager GetFileList:host complate:^(NSArray * _Nonnull array) {
        weakSelf.fileList = [[array pathsMatchingExtensions:@[@"txt"]] copy];
        [weakSelf.fileList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            dispatch_async(weakSelf.queue, ^{
                dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                NSString *fileUrl = [host stringByAppendingPathComponent:obj];
                NSLog(@"--------%@",fileUrl);
                [FileListManager GetFileString:fileUrl complate:^(NSString * _Nonnull string) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.textView.text = [weakSelf.textView.text stringByAppendingFormat:@"\n%@",fileUrl];
                    });
                    if (![string isEqualToString:@""]) {
                        NSString* tvfile = [fpath stringByAppendingPathComponent:obj];
                        if ([fm fileExistsAtPath:tvfile]) {
                            [fm removeItemAtPath:tvfile error:nil];
                        }
                        NSError *error;
                        [string writeToFile:tvfile atomically:true encoding:NSUTF8StringEncoding error:&error];
                    }
                    dispatch_semaphore_signal(sem);
                }];
                dispatch_wait(sem, DISPATCH_TIME_FOREVER);
            });
        }];
        dispatch_barrier_async(weakSelf.queue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
            });
        });
    }];
}

- (void)uploadTvFiles:(void(^)(void))block {
    NSString *fpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *host = self.textField.text;
    NSFileManager *fm = [NSFileManager defaultManager];
    __weak typeof(self)weakSelf = self;
    NSArray *fileNames = [[[fm contentsOfDirectoryAtPath:fpath error:nil] pathsMatchingExtensions:@[@"txt"]] copy];
    [fileNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileName = obj;
        NSString *filePath = [fpath stringByAppendingPathComponent:fileName];
        NSString *text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        dispatch_async(weakSelf.queue, ^{
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            [FileListManager PostFileString:host param:@{@"data":text,@"fileName":fileName} complate:^(NSString *string) {
                NSLog(@"%@",string);
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.textView.text = [weakSelf.textView.text stringByAppendingFormat:@"\n%@",string];
                });
                dispatch_semaphore_signal(sem);
            }];
            dispatch_wait(sem, DISPATCH_TIME_FOREVER);
        });
    }];
    dispatch_barrier_async(self.queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    });
}
@end