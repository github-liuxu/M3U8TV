//
//  WebListViewController.m
//  TVOnLine
//
//  Created by 刘东旭 on 2020/5/22.
//  Copyright © 2020 刘东旭. All rights reserved.
//

#import "WebListViewController.h"
#import "WebViewController.h"
#import "ConvertTXT.h"

@interface WebListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation WebListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, 44, 44);
    [self.button setTitle:@"Done" forState:UIControlStateNormal];
    [self.button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.button];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"WebListCell"];
    NSString* fpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.filePath = [fpath stringByAppendingPathComponent:@"weblist.txt"];
    self.dataSource = [[ConvertTXT alloc] initTextWith:self.filePath].array;
    [self.tableView reloadData];
}

- (UIView *)leftNavigationBarItemView {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.frame = CGRectMake(0, 0, 30, 44);
    [self.backButton setTitle:@"Add" forState:UIControlStateNormal];
    [self.backButton setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(leftNavButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return self.backButton;
}

- (void)leftNavButtonClick:(UIButton *)button {
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

- (void)buttonClick {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AVPlayerPlay" object:nil];
    [self dismissViewControllerAnimated:true completion:NULL];
}

- (IBAction)sendClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AVPlayerPause" object:nil];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WebViewController *web = [story instantiateViewControllerWithIdentifier:@"WebViewController"];
    web.urlString = self.textField.text;
    [self.navigationController pushViewController:web animated:true];
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

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    id object = [self.dataSource objectAtIndex:fromIndexPath.row];
    [self.dataSource removeObjectAtIndex:fromIndexPath.row];
    [self.dataSource insertObject:object atIndex:toIndexPath.row];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WebListCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    NSDictionary*dic = self.dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@   %@",dic[@"name"],dic[@"url"]];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

#pragma Mark 左滑按钮 iOS8以上
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AVPlayerPause" object:nil];
    NSDictionary*dic = self.dataSource[indexPath.row];
    NSString *urlString = dic[@"url"];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    WebViewController *web = [story instantiateViewControllerWithIdentifier:@"WebViewController"];
    web.urlString = urlString;
    [self.navigationController pushViewController:web animated:true];
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
    return UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft;
}

@end
