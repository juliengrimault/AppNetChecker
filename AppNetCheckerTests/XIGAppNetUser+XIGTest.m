//
// Created by julien on 24/3/13.
//
//


#import "XIGAppNetUser+XIGTest.h"


@implementation XIGAppNetUser (XIGTest)

+ (instancetype)testUser:(NSInteger)n
{
    XIGAppNetUser *user = [[XIGAppNetUser alloc] init];
    user.screenName = [NSString stringWithFormat:@"user%d", n];
    user.followerCount = @(n);
    user.followingCount = @(n);
    return user;
}

@end