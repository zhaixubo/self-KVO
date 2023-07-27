//
//  NSObject+ZXBKVO.h
//  自定义KVO
//
//  Created by 翟旭博 on 2023/7/27.
//

#import <Foundation/Foundation.h>
#import "ZXBKVOInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZXBKVO)
//接口设计 ，需要什么属性呢？ 观察者，被观察者的属性，对应条件下发生的改变的回调。
- (void)ZXB_addObserver:(NSObject *)observer keyPath:(NSString *)keyPath changeBlock:(ZXBKVOBlock)changeBlock;

- (void)ZXB_removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath;
@end

NS_ASSUME_NONNULL_END
