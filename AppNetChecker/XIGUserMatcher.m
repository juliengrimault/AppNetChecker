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
@property (nonatomic, strong) XIGAppNetUser *appNetUser;
@property (atomic) BOOL finishedCheckingAppNet; //atomic on purpose, the RACSignal might come back on another thread
@end
@implementation XIGUserMatcher

- (instancetype)initWithTwitterUser:(XIGTwitterUser *)twitterUser appNetClient:(XIGAppNetClient *)client
{
    self = [super init];
    if (self) {
        _twitterUser = twitterUser;
        [self fetchAppNetUserWithClient:client];
    }
    return self;
}

- (void)fetchAppNetUserWithClient:(XIGAppNetClient *)client
{
    @weakify(self);
    [[[client userWithScreenName:self.twitterUser.screenName] catchTo:[RACSignal return:nil]] subscribeNext:^(id x) {
        @strongify(self);
        self.appNetUser = x;
    } completed:^{
        @strongify(self);
        self.finishedCheckingAppNet = YES;
    }];
}


@end
