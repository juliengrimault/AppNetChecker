//
//  XIGTwitterUser+XIGTest.m
//  AppNetChecker
//
//  Created by Julien Grimault on 26/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterUser+XIGTest.h"

@implementation XIGTwitterUser (XIGTest)

+ (instancetype)testUser:(NSInteger)n
{
    XIGTwitterUser* user = [[XIGTwitterUser alloc] init];
    user.userId = n;
    user.name = [NSString stringWithFormat:@"User %d", n];
    user.screenName = [NSString stringWithFormat:@"user%d", n];
    user.profileImageURL = nil;
    return user;
}

+(NSArray*)testUsers:(NSRange)range
{
    NSMutableArray* users = [NSMutableArray arrayWithCapacity:range.length];
    for(int i = range.location; i < range.location + range.length; ++i) {
        XIGTwitterUser* u = [XIGTwitterUser testUser:i];
        [users addObject:u];
    }
    return [users copy];
}
@end
