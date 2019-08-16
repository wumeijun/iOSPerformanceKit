//
//  PerformanceManager.m
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/14.
//  Copyright © 2019 soul. All rights reserved.
//

#import "PerformanceManager.h"
#import "EntryView.h"

static PerformanceManager *manager = nil;

@interface PerformanceManager ()

@property (nonatomic, strong) NSMutableArray *cpuUsages;
@property (nonatomic, strong) EntryView *entryView;

@end


@implementation PerformanceManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)install
{
    [self initEntry];
}

- (void)initEntry{
    _entryView = [[EntryView alloc] init];
    [_entryView makeKeyAndVisible];
}


@end
