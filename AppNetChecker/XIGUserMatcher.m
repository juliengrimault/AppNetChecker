//
//  XIGUserMatcher.m
//  AppNetChecker
//
//  Created by Julien Grimault on 2/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGUserMatcher.h"
#import "XIGAppNetClient.h"
#import "XIGAppNetClient.h"

@interface XIGUserMatcher()
@end
@implementation XIGUserMatcher

- (instancetype)initWithTwitterUser:(XIGTwitterUser *)twitterUser appNetUser:(XIGAppNetUser *)appNetUser
{
    self = [super init];
    if (self) {
        _twitterUser = twitterUser;
        _appNetUser = appNetUser;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@>",self.class, self.twitterUser.screenName];
}
@end
