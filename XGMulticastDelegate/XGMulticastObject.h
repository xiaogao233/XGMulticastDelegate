//
//  XGMulticastObject.h
//  XGMulticastDelegate-master
//
//  Created by 高昇 on 2017/10/14.
//  Copyright © 2017年 高昇. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XGMulticastObjectDelegate <NSObject>

- (void)doSomeThing:(NSString *)change;

@end

@interface XGMulticastObject : NSObject

- (void)addDelegate:(id)delegate;

- (void)removeDelegate:(id)delegate;

@end
