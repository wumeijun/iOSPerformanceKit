//
//  BatteryModel.m
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/26.
//  Copyright © 2019 soul. All rights reserved.
//

#import "BatteryModel.h"
#import <UIKit/UIKit.h>

static BatteryModel *manager = nil;

@implementation BatteryModel

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (NSString *)getBattery {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    NSString *batterytostring ;
    batterytostring = [NSString stringWithFormat:@"%0.1lf",[UIDevice currentDevice].batteryLevel * 100];
    return batterytostring;
}


@end
