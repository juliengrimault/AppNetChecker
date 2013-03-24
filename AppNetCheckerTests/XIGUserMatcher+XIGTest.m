//
// Created by julien on 24/3/13.
//
//


#import "XIGUserMatcher+XIGTest.h"
#import "XIGTwitterUser+XIGTest.h"
#import "XIGAppNetUser+XIGTest.h"


@implementation XIGUserMatcher (XIGTest)

+ (instancetype)testUserMatcher:(NSInteger)n
{
    XIGUserMatcher *matcher = [[XIGUserMatcher alloc] initWithTwitterUser:[XIGTwitterUser testUser:n]
                                                         appNetUserSignal:[RACSignal return:[XIGAppNetUser testUser:n]]];
    return matcher;
}
+(NSArray*)testUserMatchers:(NSRange)range
{
    NSMutableArray*matchers = [NSMutableArray arrayWithCapacity:range.length];
    for(int i = range.location; i < range.location + range.length; ++i) {
        XIGUserMatcher* u = [XIGUserMatcher testUserMatcher:i];
        [matchers addObject:u];
    }
    return [matchers copy];
}
@end