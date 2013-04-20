//
// Created by julien on 31/3/13.
//
//


#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACSignal (AggregateReporting)

- (RACSignal *)aggregateProgressWithStartFactory:(id (^)(void))startFactory combine:(id (^)(id running, id next))combineBlock;
- (RACSignal *)aggregateProgressWithStart:(id)start combine:(id (^)(id running, id next))combineBlock;

@end