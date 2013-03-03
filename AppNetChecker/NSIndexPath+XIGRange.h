//
//  NSIndexPath+XIGRange.h
//  AppNetChecker
//
//  Created by Julien Grimault on 3/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (XIGRange)

+ (NSArray*)indexPathsInSection:(NSInteger)section range:(NSRange)range;
@end
