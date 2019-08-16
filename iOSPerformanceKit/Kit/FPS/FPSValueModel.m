//
//  FPSValueModel.m
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/15.
//  Copyright © 2019 soul. All rights reserved.
//

#import "FPSValueModel.h"
#import <UIKit/UIKit.h>

static FPSValueModel *manager = nil;

@interface FPSValueModel ()

@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSTimeInterval lastTime;

@end

@implementation FPSValueModel

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

/*
 *获取当前fps
 */
- (void)getFps{
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        weakSelf.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [weakSelf.link addToRunLoop:runloop forMode:NSRunLoopCommonModes];
        
        [runloop run];
    });
}



- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;
    self.currentfps = fps;
    
    
}


@end
