#import "KiwiHack.h"
#import "NSArray+JGSlice.h"

SPEC_BEGIN(NSArrayJGSliceSpec)

it(@"should raise if chunk size is 0", ^{
    [[theBlock(^{
        [@[@1,@2] sliceInChunkOfSize:0];
    }) should] raise];
});

it(@"should split in equal size", ^{
    NSInteger numberOfElements = 10;
    NSMutableArray* numbers = [NSMutableArray arrayWithCapacity:10];
    for(int i = 0; i < numberOfElements; ++i) {
        [numbers addObject:@(i)];
    }
   
   NSInteger chunkSize = 2;
   NSArray* slices = [numbers sliceInChunkOfSize:chunkSize];
   [[slices should] haveCountOf:numberOfElements/chunkSize];
   [slices enumerateObjectsUsingBlock:^(NSArray* slice, NSUInteger idx, BOOL *stop) {
        [[slice should] haveCountOf:chunkSize];
        [slice enumerateObjectsUsingBlock:^(NSNumber* n, NSUInteger innerIdx, BOOL *stop) {
            [[n should] equal:@((idx * chunkSize) + innerIdx)];
        }];
    }];
});


it(@"should split in equal size except last for array size not a multiple of chunk size", ^{
    NSInteger numberOfElements = 15;
    NSMutableArray* numbers = [NSMutableArray arrayWithCapacity:10];
    for(int i = 0; i < numberOfElements; ++i) {
        [numbers addObject:@(i)];
    }
    
    NSInteger chunkSize = 4;
    NSArray* slices = [numbers sliceInChunkOfSize:chunkSize];
    [[slices should] haveCountOf:4];
    [slices enumerateObjectsUsingBlock:^(NSArray* slice, NSUInteger idx, BOOL *stop) {
        [slice enumerateObjectsUsingBlock:^(NSNumber* n, NSUInteger innerIdx, BOOL *stop) {
            [[n should] equal:@((idx * chunkSize) + innerIdx)];
        }];
    }];
});

SPEC_END