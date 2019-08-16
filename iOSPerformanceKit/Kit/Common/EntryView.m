//
//  EntryView.m
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/14.
//  Copyright © 2019 soul. All rights reserved.
//

#import "EntryView.h"
#import "CpuModel.h"
#import "MemoryModel.h"
#import "FPSValueModel.h"

@interface EntryView ()

@property (nonatomic, strong) UIButton *entryBtn;
@property (nonatomic, assign) CGFloat kEntryViewSize;
@property (nonatomic, strong) NSMutableArray *commonDataArray;
@property (nonatomic, assign) BOOL stop;

@end

@implementation EntryView

- (instancetype)init{
    _kEntryViewSize = 60;
    self = [super initWithFrame:CGRectMake(0, ScreenHeight/3, _kEntryViewSize, _kEntryViewSize)];
    if (self) {
        self.commonDataArray = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 100.f;
        self.layer.masksToBounds = YES;
        if (!self.rootViewController) {
            self.rootViewController = [[UIViewController alloc] init];
        }

        _entryBtn = [[UIButton alloc] initWithFrame:self.bounds];
        _entryBtn.backgroundColor = [UIColor redColor];
        [_entryBtn setTitle:@"开始" forState:UIControlStateNormal];
        [_entryBtn setTitle:@"停止" forState:UIControlStateSelected];
//        [_entryBtn setImage:[UIImage doraemon_imageNamed:@"doraemon_logo"] forState:UIControlStateNormal];
        _entryBtn.layer.cornerRadius = 30;
        [_entryBtn addTarget:self action:@selector(entryClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootViewController.view addSubview:_entryBtn];
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//        [self addGestureRecognizer:pan];
    }
    return self;
}

//不能让该View成为keyWindow，每一次它要成为keyWindow的时候，都要将appDelegate的window指为keyWindow
- (void)becomeKeyWindow{
    UIWindow *appWindow = [[UIApplication sharedApplication].delegate window];
    [appWindow makeKeyWindow];
}

/**
 进入工具主面板
 */
- (void)entryClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    if (btn.isSelected) {
        self.stop = NO;
        [self startThread];
    }else {
        [self stopThread];
    }
}

- (void)startThread
{
    
    [[FPSValueModel shareManager] getFps];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        while (true) {
            [self processPerformanceData];
            sleep(1);
            NSLog(@"%@",@([[FPSValueModel shareManager] currentfps]));
            if (self.stop) {
                NSLog(@"终止");
                return ;
            }
        }
    });
    
}

- (void)processPerformanceData
{
    //1、获取当前时间戳
    NSDate *now = [NSDate date];
    NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *time = [formatter1 stringFromDate:now];
    //2、获取当前cpu占用率
    NSNumber *cpuValue = [[CpuModel shareManager] getCpuUsage];

    double memoryValue = [[MemoryModel shareManager] getResidentMemory];
    
    NSInteger fpsValue = [[FPSValueModel shareManager] currentfps];
    
    NSDictionary *commonItemData = @{
                                     @"time":time,
                                     @"fps":@(fpsValue),
                                     @"CPU":cpuValue,
                                     @"memory":@(memoryValue)
                                     };

    [_commonDataArray addObject:commonItemData];

}

- (void)stopThread
{
    self.stop = YES;
    [self exportCsv:@"test1" dataSource:_commonDataArray];
}

- (NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDate *now = [NSDate date];
    NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [formatter1 stringFromDate:now];
    NSString* fileName = [[NSString alloc] initWithFormat:@"%@ performanceFile.csv",time];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}


-(void)exportCsv:(NSString*)filename dataSource:(NSArray *)arr
{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self filePath]]) {
        [[NSFileManager defaultManager] createFileAtPath: [self filePath] contents:nil attributes:nil];
    }
    
    NSOutputStream* output = [[NSOutputStream alloc] initToFileAtPath:[self filePath] append: NO];
    [output open];
    if (![output hasSpaceAvailable])
    {
        NSLog(@"No space available in %@", filename);
    }else
    {
        
        NSString* str = [[NSString alloc] initWithFormat:@"%@,%@,%@,%@\n",@"Time", @"FPS", @"CPU", @"Memory"];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [output write:data.bytes maxLength:data.length+1];

        for (int i = 0; i < arr.count; i++)
        {
            
            NSDictionary *dic = arr[i];
            NSString *time = [NSString stringWithFormat:@"%@",dic[@"time"]];
            NSString *fpsValue = [NSString stringWithFormat:@"%@",dic[@"fps"]];
            NSString *cpuValue  = [NSString stringWithFormat:@"%@",dic[@"CPU"]];
            NSString *memoryValue  = [NSString stringWithFormat:@"%@",dic[@"memory"]];

            NSString* str = [[NSString alloc] initWithFormat:@"%@,%@,%@,%@\n",time, fpsValue, cpuValue, memoryValue];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            [output write:data.bytes maxLength:data.length+1];
        }
    }
    [output close];
}

@end
