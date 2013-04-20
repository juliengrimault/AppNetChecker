//
// Created by julien on 20/4/13.
//
//


#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACSignal (XIGBuffer)

- (RACSignal*)xig_buffer:(NSUInteger)count;
@end