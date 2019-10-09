//
//  BatteryModel.h
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/26.
//  Copyright © 2019 soul. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BatteryModel : NSObject

+ (instancetype)shareManager;
- (NSString *)getBattery;

@end

NS_ASSUME_NONNULL_END
