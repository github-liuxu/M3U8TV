//
//  ViewController.m
//  电视直播forMac
//
//  Created by 刘东旭 on 2019/2/20.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import "ViewController.h"
#import "ConvertTXT.h"

@interface ViewController()

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (weak) IBOutlet NSLayoutConstraint *right;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSString *fpath = [NSHomeDirectory() stringByAppendingPathComponent:@".tvlist"];
    
    NSString *listPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/list"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:fpath]) {
        [fm createDirectoryAtPath:fpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSArray *listArr = [fm contentsOfDirectoryAtPath:listPath error:nil];
    listArr = [listArr sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return obj1>obj2;
    }];
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
    [self.tableView reloadData];

    NSString *urlString = [self.dataSource.firstObject objectForKey:@"url"];
    if (urlString) {
        NSURL *url = [NSURL URLWithString:urlString];
        self.playerView.player = [AVPlayer playerWithURL:url];
        [self.playerView.player play];
    }
    
}
- (IBAction)clickList:(id)sender {
    if (self.right.constant == 0) {
        self.right.constant = -240;
    } else {
        self.right.constant = 0;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSource.count;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    //根据ID取视图
    NSTextFieldCell * view = (NSTextFieldCell *)[tableView makeViewWithIdentifier:@"cellId" owner:self];
    if (view==nil) {
        view = [[NSTextFieldCell alloc]init];
        view.backgroundColor = [NSColor clearColor];
        view.identifier = @"cellId";
    }

    NSString *name = [self.dataSource[row] objectForKey:@"name"];
    NSString *url = [self.dataSource[row] objectForKey:@"url"];
    view.stringValue = [NSString stringWithFormat:@"%@ %@",name,url];
    
    return view;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    NSString *urlString = [self.dataSource[row] objectForKey:@"url"];
    NSURL *url = [NSURL URLWithString:urlString];
    [self.playerView.player pause];
    self.playerView.player = [AVPlayer playerWithURL:url];
    [self.playerView.player play];
    return YES;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
