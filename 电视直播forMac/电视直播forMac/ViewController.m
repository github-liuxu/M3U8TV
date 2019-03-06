//
//  ViewController.m
//  电视直播forMac
//
//  Created by 刘东旭 on 2019/2/20.
//  Copyright © 2019年 刘东旭. All rights reserved.
//

#import "ViewController.h"
#import "ConvertTXT.h"
#import "InfoWindowController.h"

@interface ViewController()

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (weak) IBOutlet NSLayoutConstraint *right;
@property (nonatomic, strong) NSDictionary *currentDic;

@property (nonatomic, strong) InfoWindowController *infoWindow;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.right.constant = -240;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSString *fpath = [NSHomeDirectory() stringByAppendingPathComponent:@"tvlist"];
    
    NSString *listPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/list"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:fpath]) {
        NSError *error;
        [fm createDirectoryAtPath:fpath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSArray *listArr = [fm contentsOfDirectoryAtPath:listPath error:nil];
    listArr = [listArr sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return obj1>obj2;
    }];
    [listArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filestr = [fpath stringByAppendingPathComponent:obj];
        if (![fm fileExistsAtPath:filestr]) {
            [fm copyItemAtPath:[listPath stringByAppendingPathComponent:obj] toPath:filestr error:nil];
        }
    }];
    self.filePath = [fpath stringByAppendingPathComponent:listArr.firstObject];
    
    self.dataSource = [[ConvertTXT alloc] initTextWith:self.filePath].array;
    [self.tableView reloadData];
    
    self.currentDic = self.dataSource.firstObject;
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

- (IBAction)addClick:(id)sender {
    NSStoryboard *st = [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NSWindowController *window = [st instantiateControllerWithIdentifier:@"AddWindow"];
    InfoWindowController *infoController = (InfoWindowController *)window.contentViewController;
    infoController.delegate = self;
    infoController.identify = @"Add";
    [[NSApplication sharedApplication] runModalForWindow:window.window];
}

- (IBAction)listClick:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt: @"选择"];
    [openPanel setCanChooseFiles:YES];  //是否能选择文件file
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseDirectories = NO;
    openPanel.allowedFileTypes = [NSArray arrayWithObjects: @"txt", nil];
    NSURL *openpath = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"tvlist"] isDirectory:YES];
    [openPanel setDirectoryURL:openpath];
    __weak typeof(self)weakSelf = self;
    [openPanel beginSheetModalForWindow:NSApp.mainWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == 1) {
            NSURL *fileUrl = [[openPanel URLs] firstObject];
            weakSelf.filePath = [fileUrl.path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            
            weakSelf.dataSource = [[ConvertTXT alloc] initTextWith:weakSelf.filePath].array;
            [weakSelf.tableView reloadData];
            
            weakSelf.currentDic = weakSelf.dataSource.firstObject;
            NSString *urlString = [weakSelf.dataSource.firstObject objectForKey:@"url"];
            if (urlString) {
                NSURL *url = [NSURL URLWithString:urlString];
                weakSelf.playerView.player = [AVPlayer playerWithURL:url];
                [weakSelf.playerView.player play];
            }
        }
    }];
}

- (IBAction)editClick:(id)sender {
    NSStoryboard *st = [NSStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    NSWindowController *window = [st instantiateControllerWithIdentifier:@"AddWindow"];
    InfoWindowController *infoController = (InfoWindowController *)window.contentViewController;
    infoController.delegate = self;
    infoController.identify = @"Edit";
    [infoController setName:self.currentDic[@"name"] url:self.currentDic[@"url"]];
    [[NSApplication sharedApplication] runModalForWindow:window.window];
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

- (void)infoWindowController:(InfoWindowController *)infoWindowController name:(NSString *)name url:(NSString *)url {
    if ([infoWindowController.identify isEqualToString:@"Edit"]) {
        [self.currentDic setValue:name forKey:@"name"];
        [self.currentDic setValue:url forKey:@"url"];
        [self saveData:self.dataSource];
        [self.tableView reloadData];
    } else if ([infoWindowController.identify isEqualToString:@"Add"]){
        [self.dataSource addObject:@{@"name":name,@"url":url}];
        [self saveData:self.dataSource];
        [self.tableView reloadData];
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
    self.currentDic = self.dataSource[row];
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
