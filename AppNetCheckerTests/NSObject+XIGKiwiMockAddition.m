//
//  NSObject+XIGKiwiMockAddition.m
//  AppNetChecker
//
//  Created by Julien Grimault on 12/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "NSObject+XIGKiwiMockAddition.h"
#import <Kiwi/KWIntercept.h>

@implementation NSObject (XIGKiwiMockAddition)

- (void)stub:(SEL)aSelector withBlock:(id (^)(NSArray *))block {
    KWMessagePattern *messagePattern = [KWMessagePattern messagePatternWithSelector:aSelector];
    [self stubMessagePattern:messagePattern withBlock:block];
	
}

- (void)stubMessagePattern:(KWMessagePattern *)aMessagePattern withBlock:(id (^)(NSArray *params))block {
    if ([self methodSignatureForSelector:aMessagePattern.selector] == nil) {
        [NSException raise:@"KWStubException" format:@"cannot stub -%@ because no such method exists",
         NSStringFromSelector(aMessagePattern.selector)];
    }
    
    Class interceptClass = KWSetupObjectInterceptSupport(self);
    KWSetupMethodInterceptSupport(interceptClass, aMessagePattern.selector);
    KWStub *stub = [KWStub stubWithMessagePattern:aMessagePattern block:block];
    KWAssociateObjectStub(self, stub);
}
@end