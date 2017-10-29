//
//  XGMulticastDelegate.h
//  XGMulticastDelegate-master
//
//  Created by 高昇 on 2017/10/13.
//  Copyright © 2017年 高昇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XGMulticastDelegate : NSObject

- (void)addDelegate:(id)delegate;

- (void)removeDelegate:(id)delegate;

@end
