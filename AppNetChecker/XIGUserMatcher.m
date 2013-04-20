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
@property (nonatomic, strong) RACSignal *appNetUser;
@end
@implementation XIGUserMatcher

- (instancetype)initWithTwitterUser:(XIGTwitterUser *)twitterUser appNetUserSignal:(RACSignal *)appNetUserSignal
{
    self = [super init];
    if (self) {
        _twitterUser = twitterUser;
        _appNetUser = appNetUserSignal;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@>",self.class, self.twitterUser.screenName];
}
@end
