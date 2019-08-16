//
//  MemoryModel.m
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/8.
//  Copyright © 2019 soul. All rights reserved.
//

#import "MemoryModel.h"
#include <mach/mach.h>
#include <malloc/malloc.h>

#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/mman.h>

static MemoryModel *manager = nil;

@implementation MemoryModel

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (double)getResidentMemory
{
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    if(task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count) == KERN_SUCCESS) {
        return (double)vmInfo.phys_footprint / (1024 * 1024);
    } else {
        return -1.0;
    }
}

- (void)updateOutputInfo
{
    //用M单位保存数据
//    GT_OUT_SET("App Memory", false, "%.2fM", _appMemory / M_GT_MB);
}



@end
