//
//  ZXBKVOInfo.m
//  自定义KVO
//
//  Created by 翟旭博 on 2023/7/27.
//

#import "ZXBKVOInfo.h"

@implementation ZXBKVOInfo
- (instancetype)initWithObserver:(id)observer key:(NSString *)key changeBlock:(ZXBKVOBlock)changeBlock {
    if (self = [super init]) {
        _key = key;
        _observer = observer;
        _changeBlock = changeBlock;
    }
    return self;
}
@end
