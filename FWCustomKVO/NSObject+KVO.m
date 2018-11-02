//
//  NSObject+KVO.m
//  FWCustomKVO
//
//  Created by luxu on 2018/11/1.
//  Copyright © 2018年 lx. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

static const void * kFWKVOAssociateKey = "FWKVOAssociateKey";
static NSString * kFWKVOClassPrefix = @"FWKVOClassPrefix_";

@implementation NSObject (KVO)

# pragma mark --姿势1
//- (void)fw_addObserver:(NSObject *)observer forKey:(NSString *)key callBack:(FWObserverBlock)block {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        SEL originalSel = NSSelectorFromString(setterForKey(key));
//        SEL targetSel = NSSelectorFromString(@"origin_setter:");
//        Method originalMethod = class_getInstanceMethod([self class], originalSel);
//        Method targetMethod = class_getInstanceMethod([self class], targetSel);
//        // addMethod判断  因为当前类（或父类）可能已经有该method了
//        BOOL addRet = class_addMethod([self class], targetSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
//        if (!addRet) {
//            method_setImplementation(targetMethod, method_getImplementation(originalMethod));
//        }
//        // 替换原来setter方法的IMP
//        method_setImplementation(originalMethod, (IMP)fw_setter);
//    });
//
//    // 关联对象
//    NSMutableArray *observers = objc_getAssociatedObject(self, kFWKVOAssociateKey);
//    if (!observers) { // 没有关联
//        observers = [NSMutableArray array];
//        objc_setAssociatedObject(self, kFWKVOAssociateKey, observers, OBJC_ASSOCIATION_RETAIN);
//    }
//    FWObserverModel *model = [[FWObserverModel alloc] initWithObserver:observer key:key block:block];
//    [observers addObject:model];
//}
//
//void fw_setter(id self,SEL _cmd,id newValue) {
//    NSString *setter = NSStringFromSelector(_cmd);
//    NSString *getter = getterForKey(setter);
//    id oldValue = [self valueForKey:getter]; // kvc获取更改前的值
//    // 获取关联对象   block回调
//    NSMutableArray *observers = objc_getAssociatedObject(self, kFWKVOAssociateKey);
//    for (FWObserverModel *model  in observers) {
//        if ([model.key isEqualToString:model.key]) {
//            model.block(self, getter, oldValue, newValue);
//        }
//    }
//
//    // 调用setter原始方法
//    SEL selector = NSSelectorFromString(@"origin_setter:");
//    // 1.
//    ((void (*)(id,SEL,id))objc_msgSend)(self,selector,newValue);
//    // 2.
////    void (*objc_msgSendCasted)(id,SEL,id) = (void *)objc_msgSend;
////    objc_msgSendCasted(self,selector,newValue);
//    // 3.
////    [self performSelector:selector withObject:newValue];
//}

# pragma mark --姿势2
- (void)fw_addObserver:(NSObject *)observer forKey:(NSString *)key callBack:(FWObserverBlock)block {
    SEL setterSel = NSSelectorFromString(setterForKey(key));
    Class cls = object_getClass(self);
    NSString *className = NSStringFromClass(cls);
    // 类没有更改过
    if (![className hasPrefix:kFWKVOClassPrefix]) {
        // 创建自定义KVO类
        Class cls_kvo = [self makeKVOClassWithOriginClassName:className];
        object_setClass(self, cls_kvo); // isa指向创建的子类
    }
    
    // 更改创建的KVO类的setter方法
    if (![self hasSelector:setterSel]) {
        Method setterMethod = class_getInstanceMethod([self class], setterSel);
        class_addMethod(object_getClass(self), setterSel, (IMP)fw_setter, method_getTypeEncoding(setterMethod));
    }
    
    // 关联对象
    NSMutableArray *observers = objc_getAssociatedObject(self, kFWKVOAssociateKey);
    if (!observers) { // 没有关联
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, kFWKVOAssociateKey, observers, OBJC_ASSOCIATION_RETAIN);
    }
    FWObserverModel *model = [[FWObserverModel alloc] initWithObserver:observer key:key block:block];
    [observers addObject:model];
}

- (Class)makeKVOClassWithOriginClassName:(NSString *)className {
    NSString *KVOClassName = [kFWKVOClassPrefix stringByAppendingString:className];
    Class cls_kvo = NSClassFromString(KVOClassName);
    if (cls_kvo) {
        return cls_kvo;
    }
    Class cls_base = object_getClass(self);
    // 创建子类
    cls_kvo = objc_allocateClassPair(cls_base, KVOClassName.UTF8String, 0);
    
    // 更改class方法 调用父类的 (迷惑作用)
    Method classMethod = class_getInstanceMethod(cls_base, @selector(class));
    class_addMethod(cls_kvo, @selector(class), method_getImplementation(classMethod), method_getTypeEncoding(classMethod));
    objc_registerClassPair(cls_kvo);
    
    return cls_kvo;
}

void fw_setter(id self,SEL _cmd,id newValue) {
    NSString *setter = NSStringFromSelector(_cmd);
    NSString *getter = getterForKey(setter);
    id oldValue = [self valueForKey:getter]; // kvc获取更改前的值
    // 获取关联对象   block回调
    NSMutableArray *observers = objc_getAssociatedObject(self, kFWKVOAssociateKey);
    for (FWObserverModel *model  in observers) {
        if ([model.key isEqualToString:model.key]) {
            model.block(self, getter, oldValue, newValue);
        }
    }
    
    // 调用setter原始方法 即自定义KVO类的父类方法
    struct objc_super superClass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    objc_msgSendSuperCasted(&superClass, _cmd, newValue);
}

- (void)fw_removeObserver:(NSObject *)observer forKey:(NSString *)key {
    NSMutableArray *observers = objc_getAssociatedObject(self, kFWKVOAssociateKey);
    FWObserverModel *removeObserver;
    for (FWObserverModel *object in observers) {
        if ([object.key isEqualToString:key] && object.observer == observer) {
            removeObserver = object;
        }
    }
    [observers removeObject:removeObserver];
}

- (BOOL)hasSelector:(SEL)selector {
    Class cls = object_getClass(self);
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(cls, &count);
    for (int i = 0; i < count; i ++) {
        Method method = methodList[i];
        SEL sel = method_getName(method);
        if (sel == selector) {
            free(methodList);
            return YES;
        }
    }
    free(methodList);
    return NO;
}

NSString * setterForKey(NSString *key) {
    NSString *firstLetter = [[key substringToIndex:1] uppercaseString];
    NSString *remainingLetters = [key substringFromIndex:1];
    NSString *setter = [NSString stringWithFormat:@"set%@%@:", firstLetter, remainingLetters];
    return setter;
}

NSString * getterForKey(NSString *key) {
    NSRange range = NSMakeRange(3, key.length - 4);
    NSString *getter = [key substringWithRange:range];
    NSString *firstLetter = [[getter substringToIndex:1] lowercaseString];
    getter = [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstLetter];
    return getter;
}

@end
