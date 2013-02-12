//
//  NSObject+XIGKiwiMockAddition.h
//  AppNetChecker
//
//  Created by Julien Grimault on 12/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Kiwi/Kiwi.h>

@interface NSObject (XIGKiwiMockAddition)

- (void)stub:(SEL)aSelector withBlock:(id (^)(NSArray *params))block;
@end
