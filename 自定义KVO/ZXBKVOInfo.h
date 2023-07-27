//
//  ZXBKVOInfo.h
//  自定义KVO
//
//  Created by 翟旭博 on 2023/7/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZXBKVOBlock)(id observer, NSString *key, id oldValue, id newValue);

@interface ZXBKVOInfo : NSObject
@property (nonatomic, weak) id observer;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) ZXBKVOBlock changeBlock;

- (instancetype)initWithObserver:(id)observer key:(NSString *)key changeBlock:(ZXBKVOBlock)changeBlock;
@end

NS_ASSUME_NONNULL_END
