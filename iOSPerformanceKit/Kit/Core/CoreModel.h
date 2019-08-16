//
//  CoreModel.h
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/8.
//  Copyright © 2019 soul. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreModel : NSObject
{
    NSMutableDictionary *_monitorDict;
    NSThread            *_monitorThread;
}

- (void)handleTick;
+ (instancetype)shareManager;

@end

NS_ASSUME_NONNULL_END
