//
//  NSArray+JGSlice.h
//  AppNetChecker
//
//  Created by Julien Grimault on 23/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (JGSlice)

- (NSArray*)sliceInChunkOfSize:(NSUInteger)size;
@end
