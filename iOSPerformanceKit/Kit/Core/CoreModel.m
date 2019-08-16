//
//  CoreModel.m
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/8.
//  Copyright © 2019 soul. All rights reserved.
//

#import "CoreModel.h"

static CoreModel *manager = nil;

@implementation CoreModel


+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _monitorDict = [[NSMutableDictionary alloc] init];
        _monitorThread = nil;
        [self threadStart];
    }
    
    return self;
}

- (void)threadStart
{
    if (_monitorThread == nil) {
        _monitorThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadProc:) object:nil];
        _monitorThread.name = [NSString stringWithFormat:@"Core_%@", NSStringFromClass([self class])];
        [_monitorThread start];
    }
}

- (void)threadProc:(id)obj
{
    while (TRUE) {
        
        @autoreleasepool {
            if ([[NSThread currentThread] isCancelled]) {
                [NSThread exit];
            }
            
            [self handleTick];
            [NSThread sleepForTimeInterval:1];
        }
        
    }
}


- (void)handleTick
{
    NSArray *array = nil;
    @synchronized (_monitorDict) {
        array = [[_monitorDict allKeys] copy];
    }
    
    //采集所有需要监控的指标
    for (int i = 0; i < [array count]; i++) {
        id key = [array objectAtIndex:i];
        
        
//        GTMonitorObj *obj = [_monitorDict objectForKey:key];
//        if ([obj needMonitor] == YES) {
//            //            [[NSClassFromString(key) sharedInstance] handleTick];
//            [[[obj aClass] sharedInstance] handleTick];
//        }
    }
}



@end
