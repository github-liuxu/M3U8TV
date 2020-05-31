//
//  AdvanceViewController.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/5/1.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "AdvanceViewController.h"
#import "FileListManager.h"
#import "CrashListViewController.h"
#if DEBUG
#import "FLEXManager.h"
#endif
#import <BaiduOauth2/BaiduOauth2.h>
#import "LDXNetKit.h"

@interface AdvanceViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndictator;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSArray <QTList*>*fileList;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) FileInfo *dlinkFileInfo;
@property (nonatomic, strong) NSMutableArray *dlinks;

@end

@implementation AdvanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.queue = dispatch_queue_create("NvUploadRequest", DISPATCH_QUEUE_CONCURRENT);
    self.dlinks = [NSMutableArray array];
    self.activityIndictator.hidden = true;
    [self.activityIndictator stopAnimating];
}

- (IBAction)tapClick:(UITapGestureRecognizer *)sender {
    [self.textField resignFirstResponder];
    [self.textView resignFirstResponder];
}

- (IBAction)downloadClick:(UIButton *)sender {
    BaiduOauth2ViewController *baidu = [[BaiduOauth2ViewController alloc] initWithNibName:@"BaiduOauth2ViewController" bundle:[NSBundle bundleForClass:[BaiduOauth2ViewController class]]];
    baidu.url = @"https://openapi.baidu.com/oauth/2.0/authorize?response_type=token&client_id=gGB3c1nlIenzsqWV7G4dqNpg&redirect_uri=oob&scope=netdisk";
    baidu.delegate = self;
    [self addChildViewController:baidu];
    [self.view addSubview:baidu.view];
    baidu.view.frame = self.view.bounds;
    [baidu didMoveToParentViewController:self];
}

- (void)oauthLoginSuccess:(BaiduOauth2ViewController *)baiduOauthViewController info:(NSDictionary *)info {
    NSLog(@"%@",info);
    [baiduOauthViewController removeFromParentViewController];
    [baiduOauthViewController.view removeFromSuperview];
    [baiduOauthViewController didMoveToParentViewController:nil];

    [[info allKeys] enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         [[NSUserDefaults standardUserDefaults] setObject:info[obj] forKey:obj];
     }];
    
    self.activityIndictator.hidden = false;
    [self.activityIndictator startAnimating];
    [self downloadTvFiles:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndictator stopAnimating];
        });
    }];
}

- (void)oauthLoginFail:(BaiduOauth2ViewController *)baiduOauthViewController info:(NSDictionary *)info {
    [baiduOauthViewController removeFromParentViewController];
    [baiduOauthViewController.view removeFromSuperview];
    [baiduOauthViewController didMoveToParentViewController:nil];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AVPlayerPlay" object:nil];
    [self.activityIndictator removeFromSuperview];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)downloadFromWeb:(id)sender {
    [self.delegate updateFromWeb];
}

- (IBAction)flexClick:(UIButton *)sender {
#if DEBUG
    [[FLEXManager sharedManager] showExplorer];
#endif
}

- (IBAction)show:(id)sender {
    CrashListViewController *listVC = [CrashListViewController new];
    listVC.delegate = self;
    listVC.emailAddress = @"chuyang009@163.com";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:listVC];
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)backClick {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)downloadTvFiles:(void(^)(void))block {
    [self.dlinks removeAllObjects];
    NSString *fpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    NSString *path = [NSString stringWithFormat:@"https://pan.baidu.com/rest/2.0/xpan/file?method=list&access_token=%@&dir=/TVList&start=0&limit=1000",access_token];
    //获取文件列表
    __weak typeof(self)weakSelf = self;
    dispatch_async(weakSelf.queue, ^{
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [FileListManager GetFileList:path cls:[QTTopLevel class] complate:^(QTTopLevel * _Nonnull obj) {
            weakSelf.fileList = obj.list;
            dispatch_semaphore_signal(sem);
        }];
        dispatch_wait(sem, DISPATCH_TIME_FOREVER);
    });
    //获取文件下载路径
    dispatch_barrier_async(weakSelf.queue, ^{
        NSLog(@"获取文件列表成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.textView.text = [weakSelf.textView.text stringByAppendingFormat:@"\n%@",@"获取文件列表成功"];
        });
    });

    //获取文件下载路径
    dispatch_async(weakSelf.queue, ^{
        NSString *fsId = @"[";
        for (int i = 0; i < weakSelf.fileList.count; i++) {
            QTList *obj = weakSelf.fileList[i];
            if (i == weakSelf.fileList.count - 1) {
                fsId = [NSString stringWithFormat:@"%@%ld]",fsId,obj.fsID];
            } else {
                fsId = [NSString stringWithFormat:@"%@%ld,",fsId,obj.fsID];
            }
        }
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        NSString *getDlink = [NSString stringWithFormat:@"https://pan.baidu.com/rest/2.0/xpan/multimedia?method=filemetas&fsids=%@&dlink=1&access_token=%@",fsId,access_token];
        [FileListManager GetFileList:getDlink cls:[FileInfo class]  complate:^(FileInfo* _Nonnull fileInfo) {
            weakSelf.dlinkFileInfo = fileInfo;
            for (int i = 0; i < fileInfo.list.count; i++) {
                NSString *string = fileInfo.list[i].dlink;
                if (string) {
                    [weakSelf.dlinks addObject:string];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.textView.text = [weakSelf.textView.text stringByAppendingFormat:@"\n%@",string];
                    });
                }
            }
            dispatch_semaphore_signal(sem);
        }];
        dispatch_wait(sem, DISPATCH_TIME_FOREVER);
    });
    //下载文件
    dispatch_barrier_async(weakSelf.queue, ^{
        NSLog(@"获取文件下载路径成功");
    });
    //获取文件下载路径
    dispatch_async(weakSelf.queue, ^{
        FileInfo *m_fileInfo = weakSelf.dlinkFileInfo;
        for (int i = 0; i < weakSelf.dlinks.count; i++) {
            QTDlinkList* obj = m_fileInfo.list[i];
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            NSString *downloadUrl = [NSString stringWithFormat:@"%@&access_token=%@",weakSelf.dlinks[i],access_token];
            [FileListManager GetFileString:downloadUrl complate:^(NSString * _Nonnull string) {
                NSLog(@"%@",string);
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.textView.text = [weakSelf.textView.text stringByAppendingFormat:@"\n%@",string];
                });
                if (![string isEqualToString:@""] && string != nil) {
                    NSString* tvfile = [fpath stringByAppendingPathComponent:obj.filename];
                    if ([fm fileExistsAtPath:tvfile]) {
                        [fm removeItemAtPath:tvfile error:nil];
                    }
                    NSError *error;
                    [string writeToFile:tvfile atomically:true encoding:NSUTF8StringEncoding error:&error];
                }
                dispatch_semaphore_signal(sem);
            }];
            dispatch_wait(sem, DISPATCH_TIME_FOREVER);
        }
    });
    dispatch_barrier_async(weakSelf.queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    });
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

- (BOOL)shouldAutorotate {
    return YES;
}
//返回直接支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}
//返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

@end
