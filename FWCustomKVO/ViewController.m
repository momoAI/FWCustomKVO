//
//  ViewController.m
//  FWCustomKVO
//
//  Created by luxu on 2018/11/1.
//  Copyright © 2018年 lx. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+KVO.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *text;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.text = @"1";
    // 系统KVO
    //    [self addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self fw_addObserver:self forKey:@"text" callBack:^(id observer, NSString *key, id oldValue, id newValue) {
        NSLog(@"observer oldValue:%@=====>newValue:%@",oldValue,newValue);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *text = [NSString stringWithFormat:@"%i",arc4random()%100];
    NSLog(@"text change to %@",text);
    self.text = text;
}

- (void)setText:(NSString *)text {
    _text = text;
    NSLog(@"origin setter:%@",text);
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    NSString *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
//    NSString *newValue = [change objectForKey:NSKeyValueChangeNewKey];
//    NSLog(@"observer oldValue:%@=====>newValue:%@",oldValue,newValue);
//}

@end
