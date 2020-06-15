//
//  ListViewController.m
//  电视直播
//
//  Created by 刘东旭 on 2018/12/21.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "ListViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ConvertTXT.h"
#import "GetAVList.h"
#import "PlayerViewController.h"
#import "ListView.h"
#import "AdvanceViewController.h"

@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *fileTableView;

@property (nonatomic, strong) NSMutableArray *fileList;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *SwitchButton;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (nonatomic, assign) BOOL isAvPlayer;//是否使用avplayer
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstant;

@end

@implementation ListViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ((ListView*)self.view).delegate = self;
    [self.fileTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellFileList"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    NSString *fpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *listPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"list"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *listArr = [fm contentsOfDirectoryAtPath:listPath error:nil];
    BOOL first = [[NSUserDefaults standardUserDefaults] boolForKey:@"First"];
    if (!first) {
        [listArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *filestr = [fpath stringByAppendingPathComponent:obj];
            if (![fm fileExistsAtPath:filestr]) {
                [fm copyItemAtPath:[listPath stringByAppendingPathComponent:obj] toPath:filestr error:nil];
            }
        }];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"First"];
    }
    self.filePath = [fpath stringByAppendingPathComponent:@"1-tv.txt"];
    self.dataSource = [[ConvertTXT alloc] initTextWith:self.filePath].array;
    [self.tableView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(didSelectUrlString:)]) {
        NSDictionary*dic = [self.dataSource firstObject];
        NSURL * url = [NSURL URLWithString:dic[@"url"]];
        [self.delegate didSelectUrlString:url];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airdropReceiveTxtFile:) name:@"AirdropReceiveFile" object:nil];
    
}

- (void)airdropReceiveTxtFile:(NSNotification *)notifcation {
    NSDictionary *userInfo = notifcation.userInfo;
    NSString *filePath = userInfo[@"filePath"];
    NSMutableArray *dataSource = [[ConvertTXT alloc] initTextWith:filePath].array;
    if (dataSource.count > 0) {
        self.dataSource = dataSource;
    }
    [self.tableView reloadData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self resetViewPosition];
}

- (void)resetViewPosition {
    if (self.rightConstant.constant != 0) {
        return;
    }
    self.rightConstant.constant = -270;
    self.fileTableView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.button.alpha = 0.3;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - ListViewDelegate
//用于判断当前view自身是否需要相应
- (BOOL)isNeedResponse:(CGPoint)point {
    if (self.rightConstant.constant == 0) {
        return true;
    } else {
        return false;
    }
}

#pragma mark - 按钮点击事件
- (IBAction)shareFilePath:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(shareFilePath:)]) {
        [self.delegate shareFilePath:self.filePath];
    }
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:self.filePath]] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:NULL];
}
    
- (IBAction)buttonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(buttonClick:)]) {
        [self.delegate buttonClick:button];
    }
    if (self.tableView.frame.origin.x < self.view.bounds.size.width - 10) {
        [self resetViewPosition];
    } else {
        self.rightConstant.constant = 0;
        [UIView animateWithDuration:0.3 animations:^{
            button.alpha = 0.6;
            [self.view layoutIfNeeded];
        }];
    }
}
    
- (IBAction)editClick:(UIButton *)button {
    if (self.tableView.editing) {
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        [self saveData:self.dataSource];
    } else {
        [button setTitle:@"OK" forState:UIControlStateNormal];
    }
    self.tableView.editing = !self.tableView.editing;
}

- (IBAction)listClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(listFilePath:)]) {
        [self.delegate listFilePath:button];
    }
    NSString *docpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    self.fileList = [[NSMutableArray alloc] init];
    [[fm contentsOfDirectoryAtPath:docpath error:nil] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isEqualToString:@".DS_Store"] && ![obj isEqualToString:@"Inbox"] && ![obj isEqualToString:@"iChats"]) {
            [self.fileList addObject:obj];
        }
    }];
    
    self.fileTableView.hidden = !self.fileTableView.hidden;
    [self.fileTableView reloadData];
}

- (IBAction)switchButtonClick:(UIButton *)button {
    #if !TARGET_OS_MACCATALYST
    if ([self.delegate respondsToSelector:@selector(switchPlayer:)]) {
        [self.delegate switchPlayer:button];
    }
    #endif
}
- (IBAction)settingClick:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AVPlayerPause" object:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AdvanceViewController *advanceViewController = (AdvanceViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AdvanceViewController"];
    advanceViewController.delegate = self;
    [self presentViewController:advanceViewController animated:true completion:nil];
}

- (void)setSwitchText:(NSString *)text {
    if ([text isEqualToString:@"AV"]) {
        [self.SwitchButton setImage:[UIImage imageNamed:@"av"] forState:UIControlStateNormal];
    } else {
        [self.SwitchButton setImage:[UIImage imageNamed:@"ijk"] forState:UIControlStateNormal];
    }
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

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    if (tableView == self.tableView) {
        id object = [self.dataSource objectAtIndex:fromIndexPath.row];
        [self.dataSource removeObjectAtIndex:fromIndexPath.row];
        [self.dataSource insertObject:object atIndex:toIndexPath.row]; 
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.fileTableView) {
        return self.fileList.count;
    } else {
        return self.dataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.fileTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellFileList" forIndexPath:indexPath];
        cell.textLabel.text = self.fileList[indexPath.row];
        cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        NSDictionary*dic = self.dataSource[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@   %@",dic[@"name"],dic[@"url"]];
        cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    }
}

#pragma Mark 左滑按钮 iOS8以上
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.fileTableView) {
        //添加一个删除按钮
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //先删数据 再删UI
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *docpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            [fm removeItemAtPath:[docpath stringByAppendingPathComponent:self.fileList[indexPath.row]] error:nil];
            [self.fileList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
        
        return @[deleteAction];
    } else {
        //添加一个删除按钮
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            //先删数据 再删UI
            [self.dataSource removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self saveData:self.dataSource];
        }];
        
        //添加一个编辑按钮
        UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"修改" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            //弹窗输入名字
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改" message:@"请输入新名字" preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                NSString *name = [self.dataSource[indexPath.row] objectForKey:@"name"];
                if (![name isEqualToString:@""]) {
                    textField.text = name;
                }
                textField.placeholder = @"此处输入名字";
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.borderStyle = UITextBorderStyleRoundedRect;
            }];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                NSString *url = [self.dataSource[indexPath.row] objectForKey:@"url"];
                if (![url isEqualToString:@""]) {
                    textField.text = url;
                }
                textField.placeholder = @"此处输入URL";
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.borderStyle = UITextBorderStyleRoundedRect;
            }];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [tableView setEditing:NO];
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *textfield = alert.textFields.firstObject;
                UITextField *textfieldurl = alert.textFields.lastObject;
                NSString *newName = textfield.text;
                NSString *newUrl = textfieldurl.text;
                if (newName == nil) {
                    newName = @"";
                }
                
                if (newUrl == nil) {
                    newUrl = @"";
                }
                
                NSMutableDictionary *mutiDic = [NSMutableDictionary dictionary];
                [mutiDic setObject:newName forKey:@"name"];
                [mutiDic setObject:newUrl forKey:@"url"];
                self.dataSource[indexPath.row] = mutiDic;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self saveData:self.dataSource];
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }];
        editAction.backgroundColor = [UIColor orangeColor];
        
        return @[deleteAction, editAction];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.fileTableView) {
        NSString *fileString = self.fileList[indexPath.row];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [path stringByAppendingPathComponent:fileString];
        [self setFilePath:filePath];
    } else {
        if ([self.delegate respondsToSelector:@selector(didSelectUrlString:)]) {
            NSDictionary*dic = self.dataSource[indexPath.row];
            __block NSString *urlString = dic[@"url"];
            if ([urlString containsString:@"http"]) {
                urlString = [urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                NSURL * url = [NSURL URLWithString:urlString];
                [self.delegate didSelectUrlString:url];
            } else {
                NSString *uurl = [NSString stringWithFormat:@"https://m.huya.com/%@",[urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""]];
                __weak typeof(self)weakSelf = self;
                [GetAVList getURL:uurl complate:^(NSString * _Nonnull urlString) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString * urlStr = [urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                        NSURL * url = [NSURL URLWithString:urlStr];
                        [weakSelf.delegate didSelectUrlString:url];
                    });
                }];
            }
        }
    }
}

- (IBAction)addTVInfo:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改" message:@"请输入新名字" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"此处输入名字";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.placeholder = @"此处输入URL";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textfield = alert.textFields.firstObject;
        UITextField *textfieldurl = alert.textFields.lastObject;
        NSString *newName = textfield.text;
        NSString *newUrl = textfieldurl.text;
        if (newName == nil) {
            newName = @"";
        }
        
        if (newUrl == nil) {
            newUrl = @"";
        }
        
        NSMutableDictionary *mutiDic = [NSMutableDictionary dictionary];
        [mutiDic setObject:newName forKey:@"name"];
        [mutiDic setObject:newUrl forKey:@"url"];
        [self.dataSource addObject:mutiDic];
        [self.tableView reloadData];
        [self saveData:self.dataSource];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setFilePath:(NSString *)filePath {
    _filePath = filePath;
    self.dataSource = [[ConvertTXT alloc] initTextWith:self.filePath].array;
    [self.tableView reloadData];
}

- (void)saveData:(NSMutableArray *)dataSource {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.filePath]) {
        [fm removeItemAtPath:self.filePath error:nil];
    }
    NSMutableString *dataString = NSMutableString.new;
    [dataSource enumerateObjectsUsingBlock:^(NSMutableDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = obj[@"name"];
        NSString *url = obj[@"url"];
        [dataString appendString:name];
        [dataString appendString:@","];
        [dataString appendString:url];
        if (idx != dataSource.count-1) {
            [dataString appendString:@"\n"];
        }
    }];
    [dataString writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)updateFromWeb {
    __weak typeof(self)weakSelf = self;
    [GetAVList getAVList:^(NSString *r) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *fpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            weakSelf.filePath = [fpath stringByAppendingPathComponent:@"1-tv.txt"];
            if ([fm fileExistsAtPath:weakSelf.filePath]) {
                [fm removeItemAtPath:weakSelf.filePath error:nil];
            }
            [[r dataUsingEncoding:NSUTF8StringEncoding] writeToFile:weakSelf.filePath atomically:true];
            NSLog(@"%@",r);
            weakSelf.dataSource = [[ConvertTXT alloc] initTextWith:weakSelf.filePath].array;
            [weakSelf.tableView reloadData];
        });
    }];
}

@end
