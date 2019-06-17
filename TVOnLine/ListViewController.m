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
#import "ViewController.h"
#import "ConvertTXT.h"

@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (nonatomic, strong) UIButton *SwitchButton;

@end

@implementation ListViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(30, 0, self.rect.size.width - 30, self.rect.size.height) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    NSString *fpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *listPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"list"];
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
    self.filePath = [fpath stringByAppendingPathComponent:listArr.firstObject];

    self.dataSource = [[ConvertTXT alloc] initTextWith:self.filePath].array;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView reloadData];
    
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, self.rect.size.height/2 - 30, 30, 60)];
    [self.view addSubview:self.button];
    [self.button setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    [self.button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.rect.size.width - 70, self.rect.size.height - 70, 40, 40)];
    [button setBackgroundColor:[UIColor colorWithRed:13/255.0 green:191.0/255.0 blue:186.0/255.0 alpha:1]];
    [button setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    button.layer.cornerRadius = 20;
    [self.view addSubview:button];
    [button addTarget:self action:@selector(addTVInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.rect.size.width - 70, self.rect.size.height - 130, 40, 40)];
    [shareButton setBackgroundColor:[UIColor colorWithRed:13/255.0 green:191.0/255.0 blue:186.0/255.0 alpha:1]];
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    shareButton.layer.cornerRadius = 20;
    [self.view addSubview:shareButton];
    [shareButton addTarget:self action:@selector(shareFilePath:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(self.rect.size.width - 70, self.rect.size.height - 190, 40, 40)];
    [editButton setBackgroundColor:[UIColor colorWithRed:13/255.0 green:191.0/255.0 blue:186.0/255.0 alpha:1]];
    [editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    editButton.layer.cornerRadius = 20;
    [self.view addSubview:editButton];
    [editButton addTarget:self action:@selector(editClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *listButton = [[UIButton alloc] initWithFrame:CGRectMake(self.rect.size.width - 70, self.rect.size.height - 250, 40, 40)];
    [listButton setBackgroundColor:[UIColor colorWithRed:13/255.0 green:191.0/255.0 blue:186.0/255.0 alpha:1]];
    [listButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
    listButton.layer.cornerRadius = 20;
    [self.view addSubview:listButton];
    [listButton addTarget:self action:@selector(listClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.SwitchButton = [[UIButton alloc] initWithFrame:CGRectMake(self.rect.size.width - 70, self.rect.size.height - 310, 40, 40)];
    [self.SwitchButton setBackgroundColor:[UIColor colorWithRed:13/255.0 green:191.0/255.0 blue:186.0/255.0 alpha:1]];
    [self.SwitchButton setImage:[UIImage imageNamed:@"av"] forState:UIControlStateNormal];
    self.SwitchButton.layer.cornerRadius = 20;
    [self.view addSubview:self.SwitchButton];
    [self.SwitchButton addTarget:self action:@selector(switchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.delegate respondsToSelector:@selector(didSelectUrlString:)]) {
        NSDictionary*dic = [self.dataSource firstObject];
        NSURL * url = [NSURL URLWithString:dic[@"url"]];
        [self.delegate didSelectUrlString:url];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airdropReceiveTxtFile:) name:@"AirdropReceiveJsonFile" object:nil];
    
}

- (void)airdropReceiveTxtFile:(NSNotificationCenter *)notifcation {
    self.dataSource = [[ConvertTXT alloc] initTextWith:self.filePath].array;
    [self.tableView reloadData];
}
    
- (void)setRect:(CGRect)rect {
    _rect = rect;
    self.view.frame = rect;
}
    
- (void)shareFilePath:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(shareFilePath:)]) {
        [self.delegate shareFilePath:self.filePath];
    }
}
    
- (void)buttonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(buttonClick:)]) {
        [self.delegate buttonClick:button];
    }
}
    
- (void)editClick:(UIButton *)button {
    if (self.tableView.editing) {
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        [self saveData:self.dataSource];
    } else {
        [button setTitle:@"OK" forState:UIControlStateNormal];
    }
    self.tableView.editing = !self.tableView.editing;
}

- (void)listClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(listFilePath:)]) {
        [self.delegate listFilePath:button];
    }
}

- (void)switchButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(switchPlayer:)]) {
        [self.delegate switchPlayer:button];
    }
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
    return UIInterfaceOrientationMaskPortrait;
}

//返回最优先显示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
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
    if ([self.delegate respondsToSelector:@selector(didSelectUrlString:)]) {
        NSDictionary*dic = self.dataSource[indexPath.row];
        NSString *urlString = dic[@"url"];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        NSURL * url = [NSURL URLWithString:urlString];
        [self.delegate didSelectUrlString:url];
    }
}

- (void)addTVInfo:(id)sender {
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

@end
