//
//  FWObserverModel.h
//  FWCustomKVO
//
//  Created by luxu on 2018/11/1.
//  Copyright © 2018年 lx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FWObserverBlock)(id observer, NSString *key, id oldValue, id newValue);

@interface FWObserverModel : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) FWObserverBlock block;

- (instancetype)initWithObserver:(NSObject *)observer key:(NSString *)key block:(FWObserverBlock)block;

@end


