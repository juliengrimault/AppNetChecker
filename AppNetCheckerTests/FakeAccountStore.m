//
//  FakeAccountStore.m
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "FakeAccountStore.h"
@interface FakeAccountStore()
@property (nonatomic, copy) ACAccountStoreRequestAccessCompletionHandler handler;
@end

@implementation FakeAccountStore

- (void)requestAccessToAccountsWithType:(ACAccountType *)accountType options:(NSDictionary *)options completion:(ACAccountStoreRequestAccessCompletionHandler)completion
{
    self.handler = completion;
}

- (void)callRequestAccessHandler
{
    if (self.handler) {
        self.handler(self.accessToReturn, self.errorToReturn);
    }
}


- (NSArray*)accountsWithAccountType:(ACAccountType *)accountType
{
    if (self.accessToReturn) {
        return self.accountsToReturn;
    }
    return nil;
}

@end
