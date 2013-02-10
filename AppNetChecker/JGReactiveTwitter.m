//
//  JGReactiveTwitter.m
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "JGReactiveTwitter.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>

@interface JGReactiveTwitter()
@property (nonatomic, strong) RACMulticastConnection* twitterAccountConnection;
@end

@implementation JGReactiveTwitter

- (ACAccountStore*)accountStore
{
    if(!_accountStore) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    @weakify(self);
    RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        RACDisposable* disposable = [RACDisposable disposableWithBlock:^{}];
        ACAccountType* twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType
                                              options:nil
                                           completion:^(BOOL granted, NSError *error) {
                                               if (!error && granted) {
                                                   NSArray* accounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                                                   [subscriber sendNext:accounts];
                                                   [subscriber sendCompleted];
                                               }
                                               else
                                               {
                                                   [subscriber sendError:error];
                                               }
                                           }];
        return disposable;
    }];
    _twitterAccountConnection = [signal multicast:[RACReplaySubject replaySubjectWithCapacity:1]];
    return self;
}

- (RACSignal*)twitterAccountSignal
{
    [self.twitterAccountConnection connect];
    return self.twitterAccountConnection.signal;
}


@end
