//
//  NSIndexPath+XIGRange.m
//  AppNetChecker
//
//  Created by Julien Grimault on 3/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "NSIndexPath+XIGRange.h"

@implementation NSIndexPath (XIGRange)

+ (NSArray*)indexPathsInSection:(NSInteger)section range:(NSRange)range
{
    NSMutableArray* insertedIndexPaths = [NSMutableArray arrayWithCapacity:range.length];
    for (int i = 0; i < range.length; ++i) {
        NSIndexPath* path = [NSIndexPath indexPathForItem:i + range.location inSection:0];
        [insertedIndexPaths addObject:path];
    }
    return [insertedIndexPaths copy];
}
@end
