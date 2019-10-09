//
//  CpuModel.h
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/8.
//  Copyright © 2019 soul. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CpuModel : NSObject
{
    float cpu_usage;
}
- (NSNumber *)getCpuUsage;
+ (instancetype)shareManager;

@end

NS_ASSUME_NONNULL_END
