//
//  FPSValueModel.h
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/8/15.
//  Copyright © 2019 soul. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FPSValueModel : NSObject

@property (nonatomic, assign) NSInteger currentfps;
+ (instancetype)shareManager;
- (void)getFps;

@end

NS_ASSUME_NONNULL_END
