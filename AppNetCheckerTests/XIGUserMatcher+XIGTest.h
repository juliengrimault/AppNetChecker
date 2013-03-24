//
// Created by julien on 24/3/13.
//
//


#import <Foundation/Foundation.h>
#import "XIGUserMatcher.h"

@interface XIGUserMatcher (XIGTest)

+ (instancetype)testUserMatcher:(NSInteger)n;
+(NSArray*)testUserMatchers:(NSRange)range;
@end