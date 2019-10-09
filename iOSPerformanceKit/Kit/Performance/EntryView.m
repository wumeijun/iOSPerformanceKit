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
#import "BatteryModel.h"
#import "InputAltertView.h"

static NSString * dataPath =  @"http://qm.soulapp-inc.cn/api/vulpix/ios_performance_view/post_data";

@interface EntryView ()

@property (nonatomic, strong) UIButton *entryBtn;
@property (nonatomic, assign) CGFloat kEntryViewSize;
@property (nonatomic, strong) NSMutableArray *commonDataArray;
@property (nonatomic, assign) BOOL stop;
@property (nonatomic, strong) NSMutableString *fps;
@property (nonatomic, strong) NSMutableString *cpu;
@property (nonatomic, strong) NSMutableString *memory;
@property (nonatomic, strong) NSMutableString *time;
@property (nonatomic, strong) InputAltertView *inputView;

@end

@implementation EntryView

- (instancetype)init{
    _kEntryViewSize = 120;
    
    self = [super initWithFrame:CGRectMake(0, ScreenHeight/3, _kEntryViewSize, _kEntryViewSize)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar + 100.f;
        self.layer.masksToBounds = YES;
        if (!self.rootViewController) {
            self.rootViewController = [[UIViewController alloc] init];
        }
        
        _entryBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _entryBtn.backgroundColor = [UIColor redColor];
        _entryBtn.accessibilityLabel = @"entryButton";
        [_entryBtn setTitle:@"开始" forState:UIControlStateNormal];
        [_entryBtn setTitle:@"停止" forState:UIControlStateSelected];
        _entryBtn.layer.cornerRadius = 30;
        [_entryBtn addTarget:self action:@selector(entryClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootViewController.view addSubview:_entryBtn];
        //        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        //        [self addGestureRecognizer:pan];
        
        _inputView = [[InputAltertView alloc] initWithFrame:self.bounds];
        [_inputView.confirmButton addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchUpInside];
        [self.rootViewController.view addSubview:_inputView];
        
    }
    return self;
}


- (void)becomeKeyWindow {
    UIWindow *appWindow = [[UIApplication sharedApplication].delegate window];
    [appWindow makeKeyWindow];
    [appWindow makeKeyAndVisible];
}

- (void)startRecord:(UIButton *)btn {
    
    if (!_inputView.textField.text.length) {
        return;
    }
    
    _inputView.hidden = YES;
    _entryBtn.hidden = NO;
    
    if (_entryBtn.isSelected) {
        self.stop = NO;
        [self startThread];
    }else {
        [self stopThread];
    }
}

- (void)entryClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    self.inputView.hidden = !btn.selected;
    btn.hidden = !self.inputView.hidden;
    
    if (!_entryBtn.isSelected) {
        [self stopThread];
    }
    
}
- (void)startThread
{
    _commonDataArray = [[NSMutableArray alloc] init];
    _fps = [[NSMutableString alloc] init];
    _cpu = [[NSMutableString alloc] init];
    _memory = [[NSMutableString alloc] init];
    _time = [[NSMutableString alloc] init];
    
    [[FPSValueModel shareManager] startMonitoring];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        while (true) {
            [self processPerformanceData];
            sleep(1);
            if (self.stop) {
                [[FPSValueModel shareManager] removeMonitoring];
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
    NSString *timeValue = [formatter1 stringFromDate:now];
    //2、获取当前cpu占用率
    NSNumber *cpuValue = [[CpuModel shareManager] getCpuUsage];
    
    double memoryValue = [[MemoryModel shareManager] getResidentMemory];
    
    NSInteger fpsValue = [[FPSValueModel shareManager] currentfps];
    
    NSString *batteryValue = [[BatteryModel shareManager] getBattery];
    
    NSDictionary *commonItemData = @{
                                     @"time":timeValue,
                                     @"fps":@(fpsValue),
                                     @"CPU":cpuValue,
                                     @"memory":@(memoryValue),
                                     @"battery":batteryValue
                                     };
    
    [_commonDataArray addObject:commonItemData];
    
    [_fps appendString:[NSString stringWithFormat:@"%@,",@(fpsValue)]];
    [_cpu appendString:[NSString stringWithFormat:@"%@,",cpuValue]];
    [_memory appendString:[NSString stringWithFormat:@"%0.f,",memoryValue]];
    [_time appendString:[NSString stringWithFormat:@"%@,",timeValue]];
    
}

- (void)stopThread
{
    self.stop = YES;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    
    NSDictionary *params = @{@"action_name":self.inputView.textField.text, @"app_version":appVersion,
                             @"cpu_data":_cpu, @"fps_data":_fps,
                             @"time":_time,@"memory_data":_memory};
    
    
    [self sendLeakResult: params];
    //    [self exportCsv:@"test1" dataSource:_commonDataArray];
}

- (NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDate *now = [NSDate date];
    NSDateFormatter* formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [formatter1 stringFromDate:now];
    NSString* fileName = [[NSString alloc] initWithFormat:@"%@%@ performanceFile.csv",time,@"文件"];
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
        NSString* str = [[NSString alloc] initWithFormat:@"%@,%@,%@,%@,%@\n",@"Time", @"FPS", @"CPU", @"Memory",@"Battery"];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [output write:data.bytes maxLength:data.length+1];
        
        for (int i = 0; i < arr.count; i++)
        {
            
            NSDictionary *dic = arr[i];
            NSString *timeValue = [NSString stringWithFormat:@" %@",dic[@"time"]];
            NSString *fpsValue = [NSString stringWithFormat:@"%@",dic[@"fps"]];
            NSString *cpuValue  = [NSString stringWithFormat:@"%@",dic[@"CPU"]];
            NSString *memoryValue  = [NSString stringWithFormat:@"%@",dic[@"memory"]];
            NSString *batteryValue  = [NSString stringWithFormat:@"%@",dic[@"battery"]];
            
            NSString* str = [[NSString alloc] initWithFormat:@"%@,%@,%@,%@,%@\n",timeValue, fpsValue, cpuValue, memoryValue,batteryValue];
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            [output write:data.bytes maxLength:data.length+1];
        }
    }
    [output close];
}


- (void)sendLeakResult:(NSDictionary *)dicData{
    NSString *boundary = @"wumeijun2019";
    NSURL *url = [NSURL URLWithString:dataPath];
    NSMutableString *bodyContent = [NSMutableString string];
    for(NSString *key in dicData.allKeys){
        id value = [dicData objectForKey:key];
        [bodyContent appendFormat:@"--%@\r\n",boundary];
        [bodyContent appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [bodyContent appendFormat:@"%@\r\n",value];
    }
    [bodyContent appendFormat:@"--%@--\r\n",boundary];
    NSData *bodyData=[bodyContent dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    [request addValue: [NSString stringWithFormat:@"%zd",bodyData.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    __autoreleasing NSError *error=nil;
    __autoreleasing NSURLResponse *response=nil;
    NSData *reciveData= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error){
        NSLog(@"出现异常%@",error);
    }else{
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
        if(httpResponse.statusCode==200){
            NSLog(@"服务器成功响应!>>%@",[[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding]);
            
        }else{
            NSLog(@"服务器返回失败>>%@",[[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding]);
            
        }
    }
    
}


@end
