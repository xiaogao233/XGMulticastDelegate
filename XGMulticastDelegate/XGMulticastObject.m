//
//  XGMulticastObject.m
//  XGMulticastDelegate-master
//
//  Created by 高昇 on 2017/10/14.
//  Copyright © 2017年 高昇. All rights reserved.
//

#import "XGMulticastObject.h"
#import <objc/runtime.h>

/* 关联对象key */
NSString *const kMulticastObjectKey = @"kMulticastObjectKey";
NSString *const kFirstKey = @"kFirstKey";

@implementation XGMulticastObject

- (void)addDelegate:(id)delegate
{
    /* 通过关联对象key找到代理数组 */
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)(kMulticastObjectKey));
    /* 不存在代理数组，创建代理数组并关联key */
    if (!delegateArray) {
        delegateArray = [NSMutableArray new];
        objc_setAssociatedObject(self, (__bridge const void *)(kMulticastObjectKey), delegateArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    /* 添加代理到代理数组 */
    [delegateArray addObject:delegate];
    
    if (![objc_getAssociatedObject(self, (__bridge const void *)(kFirstKey)) boolValue])
    {
        u_int count = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        
        for (int i = 0; i<count; i++) {
            const char *properyName = property_getName(properties[i]);
            class_addMethod([self class], [self handlerSetterNameWithPropertyName:[NSString stringWithUTF8String:properyName]], (IMP)Setter, "v@:@");
            class_replaceMethod([self class], [self handlerSetterNameWithPropertyName:[NSString stringWithUTF8String:properyName]], (IMP)Setter, "v@:@");
        }
        
        objc_setAssociatedObject(self, (__bridge const void *)(kFirstKey), [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void)removeDelegate:(id)delegate
{
    /* 通过关联对象key找到代理数组 */
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)(kMulticastObjectKey));
    /* 存在代理数组，则删除代理对象 */
    if (delegateArray) [delegateArray removeObject:delegate];
}

void Setter(id obj, SEL _cmdMe, id newName)
{
    /* 获取属性，去除set字段 */
    NSString *var = [NSStringFromSelector(_cmdMe) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
    /* 首字母小写 */
    NSString *firstCase = [var substringToIndex:1];
    var = [var stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstCase.lowercaseString];
    /* 去除末尾:号 */
    var = [var substringWithRange:NSMakeRange(0, var.length-1)];
    /* 获取旧值 */
    Ivar ivar = class_getInstanceVariable([obj class], [[NSString stringWithFormat:@"_%@",var] cStringUsingEncoding:NSUTF8StringEncoding]);
    id oldName = object_getIvar(obj, ivar);
    if (oldName != newName)
    {
        /* 重新赋值 */
        object_setIvar(obj, ivar, [newName copy]);
        /* 通过关联对象key找到代理数组 */
        NSMutableArray *delegateArray = objc_getAssociatedObject(obj, (__bridge const void *)(kMulticastObjectKey));
        for (id delegate in delegateArray) {
            if ([delegate respondsToSelector:@selector(doSomeThing:)]) {
                [delegate doSomeThing:var];
            }
        }
    }
}

- (SEL)handlerSetterNameWithPropertyName:(NSString *)propertyName
{
    /* 首字母大写 */
    propertyName = propertyName.capitalizedString;
    /* 拼接上set关键字 */
    propertyName = [NSString stringWithFormat:@"set%@:", propertyName];
    /* 返回set方法 */
    return NSSelectorFromString(propertyName);
}

@end
