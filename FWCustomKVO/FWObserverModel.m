//
//  FWObserverModel.m
//  FWCustomKVO
//
//  Created by luxu on 2018/11/1.
//  Copyright © 2018年 lx. All rights reserved.
//

#import "FWObserverModel.h"

@implementation FWObserverModel

- (instancetype)initWithObserver:(NSObject *)observer key:(NSString *)key block:(FWObserverBlock)block {
    if (self = [super init]) {
        _observer = observer;
        _key = key;
        _block = block;
    }
    return self;
}

@end
