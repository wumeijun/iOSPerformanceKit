//
//  CpuModel.m
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/8.
//  Copyright © 2019 soul. All rights reserved.
//

#import "CpuModel.h"
#include <mach/mach.h>
#include <malloc/malloc.h>

#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <mach/processor_info.h>
#import <mach/mach_host.h>

static CpuModel *manager = nil;

@implementation CpuModel

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (NSNumber *)getCpuUsage
{
    kern_return_t           kr;
    thread_array_t          thread_list;
    mach_msg_type_number_t  thread_count;
    thread_info_data_t      thinfo;
    mach_msg_type_number_t  thread_info_count;
    thread_basic_info_t     basic_info_th;
    
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return @(-1);
    }
    cpu_usage = 0;
    
    for (int i = 0; i < thread_count; i++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[i], THREAD_BASIC_INFO,(thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return @(-1);
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE))
        {
            cpu_usage += basic_info_th->cpu_usage;
        }
    }
    
    cpu_usage = cpu_usage / (float)TH_USAGE_SCALE * 100.0;
    
    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    
    return @(cpu_usage);
}



@end
