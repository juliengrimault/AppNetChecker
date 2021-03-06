//
// Created by julien on 31/3/13.
//
//


#import "RACSignal+AggregateReporting.h"


@implementation RACSignal (AggregateReporting)

- (RACSignal *)aggregateProgressWithStartFactory:(id (^)(void))startFactory combine:(id (^)(id running, id next))combineBlock {
    NSParameterAssert(startFactory != NULL);
    NSParameterAssert(combineBlock != NULL);

    return [[RACSignal createSignal:^(id<RACSubscriber> subscriber) {
        __block id runningValue = startFactory();
        return [self subscribeNext:^(id x) {
            runningValue = combineBlock(runningValue, x);
            [subscriber sendNext:runningValue];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        } completed:^{
            [subscriber sendNext:runningValue];
            [subscriber sendCompleted];
        }];
    }] setNameWithFormat:@"[%@] -aggregateWithStartFactory:combine:", self.name];
}

- (RACSignal *)aggregateProgressWithStart:(id)start combine:(id (^)(id running, id next))combineBlock {
    RACSignal *signal = [self aggregateProgressWithStartFactory:^{
        return start;
    } combine:combineBlock];

    return [signal setNameWithFormat:@"[%@] -aggregateWithStart: %@ combine:", self.name, start];
}

- (RACSignal *)progressiveCount
{
    return [self aggregateProgressWithStart:@0 combine:^id(NSNumber *current, id x) {
        NSUInteger count = [current unsignedIntegerValue];
        ++count;
        return @(count);
    }];
}
@end