//
// Created by julien on 20/4/13.
//
//



#import "RACSignal+XIGBuffer.h"


@implementation RACSignal (XIGBuffer)

- (RACSignal *)xig_buffer:(NSUInteger)count {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:count];
        RACDisposable *disposable = [self subscribeNext:^(id x) {
            [values addObject:x ? : [RACTupleNil tupleNil]];
            if (values.count % count == 0) {
                [subscriber sendNext:[RACTuple tupleWithObjectsFromArray:values convertNullsToNils:NO]];
                [values removeAllObjects];
            }
        } error:^(NSError *error){
            [subscriber sendError:error];
        } completed:^{
            if (values.count > 0)
                [subscriber sendNext:[RACTuple tupleWithObjectsFromArray:values convertNullsToNils:NO]];
            [subscriber sendCompleted];
        }];
        return disposable;
    }];
}


@end