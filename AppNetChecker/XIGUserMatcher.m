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

- (instancetype)initWithTwitterUser:(XIGTwitterUser *)twitterUser appNetClient:(XIGAppNetClient *)client
{
    self = [super init];
    if (self) {
        _twitterUser = twitterUser;
         self.appNetUser = [[client userWithScreenName:self.twitterUser.screenName] catchTo:[RACSignal return:nil]];
    }
    return self;
}


@end
