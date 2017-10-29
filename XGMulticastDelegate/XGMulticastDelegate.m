//
//  XGMulticastDelegate.m
//  XGMulticastDelegate-master
//
//  Created by 高昇 on 2017/10/13.
//  Copyright © 2017年 高昇. All rights reserved.
//

#import "XGMulticastDelegate.h"
#import <objc/runtime.h>

/* 关联对象key */
NSString *const kMulticastDelegateKey = @"kMulticastDelegateKey";

@implementation XGMulticastDelegate

- (void)addDelegate:(id)delegate
{
    /* 通过关联对象key找到代理数组 */
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)(kMulticastDelegateKey));
    /* 不存在代理数组，创建代理数组并关联key */
    if (!delegateArray) {
        delegateArray = [NSMutableArray new];
        objc_setAssociatedObject(self, (__bridge const void *)(kMulticastDelegateKey), delegateArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    /* 添加代理到代理数组 */
    [delegateArray addObject:delegate];
}

- (void)removeDelegate:(id)delegate
{
    /* 通过关联对象key找到代理数组 */
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)(kMulticastDelegateKey));
    /* 存在代理数组，则删除代理对象 */
    if (delegateArray) [delegateArray removeObject:delegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    /* 通过关联对象key找到代理数组 */
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)(kMulticastDelegateKey));
    for (id delegate in delegateArray) {
        /* 取出代理对象对应的aSelector的方法标识 */
        NSMethodSignature *sign = [delegate methodSignatureForSelector:aSelector];
        if (sign) return sign;
    }
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    /* 通过关联对象key找到代理数组 */
    NSMutableArray *delegateArray = objc_getAssociatedObject(self, (__bridge const void *)(kMulticastDelegateKey));
    for (id delegate in delegateArray) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            /* 异步转发消息 */
            [anInvocation invokeWithTarget:delegate];
        });
    }
}

- (void)doNothing{}

@end
