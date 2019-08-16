//
//  PerformanceManager.h
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/14.
//  Copyright © 2019 soul. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PerformanceManager : NSObject

+ (instancetype)shareManager;
- (void)install;

@end

NS_ASSUME_NONNULL_END
