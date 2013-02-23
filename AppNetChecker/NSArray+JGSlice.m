//
//  NSArray+JGSlice.m
//  AppNetChecker
//
//  Created by Julien Grimault on 23/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "NSArray+JGSlice.h"

@implementation NSArray (JGSlice)

- (NSArray*)sliceInChunkOfSize:(NSUInteger)size
{
    NSParameterAssert(size > 0);
    NSInteger sliceCount = ceilf(((CGFloat)self.count)/ (CGFloat)size);
    NSMutableArray* slices = [NSMutableArray arrayWithCapacity:sliceCount];
    for (int i = 0; i < sliceCount; ++i) {
        NSRange currentRange = NSMakeRange(i * size, size);
        
        if (i == sliceCount - 1) {
            currentRange = NSIntersectionRange(NSMakeRange(0, self.count), currentRange);
        }
        
        NSArray* slice = [self objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:currentRange]];
        [slices addObject:slice];
    }
    return [slices copy];
}
@end
