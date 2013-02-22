//
//  JGReactiveTwitter.m
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterAccountStore.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>
#import "XIGAccountError.h"

@interface XIGTwitterAccountStore()
@end

@implementation XIGTwitterAccountStore

- (ACAccountStore*)accountStore
{
    if(!_accountStore) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

- (RACSignal*)twitterAccounts
{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        RACDisposable* disposable = [RACDisposable disposableWithBlock:^{}];
        ACAccountType* twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType
                                                   options:nil
                                                completion:^(BOOL granted, NSError *error) {
                                                    if (!granted && !error) {
                                                        error = [self accessNotGrantedError];
                                                    }
                                                    
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
}

- (NSError*)accessNotGrantedError
{
    return [NSError errorWithDomain:ACErrorDomain code:ACErrorAccessNotGranted userInfo:nil];
}


@end
