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

@property (nonatomic, strong) CADisplayLink *displayLink;
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

- (void)startMonitoring {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    _displayLink.paused = NO;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)pauseMonitoring{
    _displayLink.paused = YES;
}

- (void)removeMonitoring{
    if (_displayLink) {
        [self pauseMonitoring];
        [_displayLink invalidate];
    }
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
    
    NSLog(@"%@反反复复韩国哈哈哈==============fps",@(fps));
}


@end
