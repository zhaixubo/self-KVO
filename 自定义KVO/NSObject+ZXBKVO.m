//
//  NSObject+ZXBKVO.m
//  自定义KVO
//
//  Created by 翟旭博 on 2023/7/27.
//

#import "NSObject+ZXBKVO.h"
#import "objc/runtime.h"
#include <objc/message.h>
static NSString * ZXBKVOPrefix = @"ZXBKVOPrefix";
static NSString * ZXBKVOObserversKey = @"ZXBKVOObserversKey";

static NSString * setterForGetter (NSObject *parameter){
    NSString *p = [NSString stringWithFormat:@"%@",parameter];
    NSString *firstCharacter = [[p substringToIndex:1] uppercaseString];
    NSString *remainingCharacters = [p substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:",firstCharacter,remainingCharacters];
}

static NSString *getterForSetter(NSString *parameter){
    NSString *result;
    
    NSRange r = [parameter rangeOfString:@"set"];
    result = [parameter substringFromIndex:r.location + r.length];
    
    NSString *firstCharacter = [result substringToIndex:1].lowercaseString;
    result = [result stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstCharacter];
    
    result = [result stringByReplacingCharactersInRange:[result rangeOfString:@":"] withString:@""];
    
    return result;
}
@implementation NSObject (ZXBKVO)
static Class ZXBKVO_Class(id self, SEL _cmd) {
    Class clazz = object_getClass(self); // kvo_class
    Class superClazz = class_getSuperclass(clazz); // origin_class
    return superClazz; // origin_class
}

//重写setter方法
static void KVO_setterIMP(id self,SEL _cmd,id newValue){
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getterForSetter(setterName);
  
    id oldValue = [self valueForKey:getterName];
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    void (*objc_msgSendSuperCasted)(void *,SEL ,id) = (void *)objc_msgSendSuper;
    objc_msgSendSuperCasted(&superClazz,_cmd,newValue);
    NSMutableArray<ZXBKVOInfo *> *observers = objc_getAssociatedObject(self, (__bridge const void *)ZXBKVOObserversKey);
    [observers enumerateObjectsUsingBlock:^(ZXBKVOInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([(NSString *)obj.key isEqualToString:getterName]) {
            obj.changeBlock(self, getterName, oldValue, newValue);
        }
    }];

}

#pragma mark - core initialize
/** implementation   */
- (void)ZXB_addObserver:(NSObject *)observer keyPath:(NSString *)keyPath changeBlock:(ZXBKVOBlock)changeBlock{
    //1. 是否实现setter方法
    Method superSetMethod = [self p_checkIsImplementionSetterWithContext:self keypath:keyPath];
    if (!superSetMethod) {
        @throw [NSException exceptionWithName:@"does't find selector" reason:@"does't imp setter metthod" userInfo:nil];
    }
    //2. 判断这个类是否是自定义KVO类
    Class clazz = object_getClass(self);
    NSString *clazzName = NSStringFromClass(clazz);
    //3. 没有就创建一个类并且让该对象的isa指向
    if (![clazzName hasPrefix:ZXBKVOPrefix]) {
        clazz = [self createKVOClassWithClassName:clazzName];
        object_setClass(self, clazz);
    }
    //重写setter方法
    const char * types = method_getTypeEncoding(superSetMethod);
    class_addMethod(object_getClass(self), NSSelectorFromString(setterForGetter(keyPath)), (IMP)KVO_setterIMP, types);
    
    
    NSMutableArray *observers = objc_getAssociatedObject(self,(__bridge const void *) ZXBKVOObserversKey);
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, (__bridge const void *) ZXBKVOObserversKey, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    ZXBKVOInfo *info = [[ZXBKVOInfo alloc] initWithObserver:observers key:keyPath changeBlock:changeBlock];
    [observers addObject:info];
}

#pragma mark - 检查是否有设置方法
- (Method)p_checkIsImplementionSetterWithContext:(NSObject *)context keypath:(NSObject *)keypath{
    //get method
    SEL selector = NSSelectorFromString(setterForGetter(keypath));
    Method setMethod = class_getInstanceMethod([self class], selector);
    return setMethod;
}

- (Class)createKVOClassWithClassName:(NSString *)className{
    NSString *kvoClazzName = [ZXBKVOPrefix stringByAppendingString:className];
    Class KVOClazz = NSClassFromString(kvoClazzName);
    if (KVOClazz) {
        return KVOClazz;
    }
    //创建
    Class superClazz = object_getClass(self);
    Class KVOClazz1 = objc_allocateClassPair(superClazz, kvoClazzName.UTF8String, 0);
   
    //获得Types类型
    Method m = class_getInstanceMethod(superClazz, @selector(class));
    const char *types = method_getTypeEncoding(m);
    class_addMethod(KVOClazz1, @selector(class), (IMP)ZXBKVO_Class, types);

    objc_registerClassPair(KVOClazz1);
    return KVOClazz1;
}

#pragma mark - 析构
- (void)ZXB_removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath{
    NSMutableArray<ZXBKVOInfo *> *observers = objc_getAssociatedObject(self, (__bridge const void *)ZXBKVOObserversKey);
    if (!observers) {
        return;
    }
    for (ZXBKVOInfo *info in observers) {
        if ([info.key isEqualToString:keyPath]) {
            [observers removeObject:info];
        }
    }
    
}
@end
