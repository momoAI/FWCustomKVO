//
//  NSObject+KVO.h
//  FWCustomKVO
//
//  Created by luxu on 2018/11/1.
//  Copyright © 2018年 lx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWObserverModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVO)

- (void)fw_addObserver:(NSObject *)observer
                forKey:(NSString *)key
             callBack:(FWObserverBlock)block;

- (void)fw_removeObserver:(NSObject *)observer forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
