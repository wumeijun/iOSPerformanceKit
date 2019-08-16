//
//  MemoryModel.h
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/8.
//  Copyright © 2019 soul. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MemoryModel : NSObject

+ (instancetype)shareManager;
- (double)getResidentMemory;

@end

NS_ASSUME_NONNULL_END
