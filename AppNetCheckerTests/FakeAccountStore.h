//
//  FakeAccountStore.h
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Accounts/Accounts.h>

@interface FakeAccountStore : ACAccountStore

@property (nonatomic) BOOL accessToReturn;
@property (nonatomic, strong) NSError* errorToReturn;
- (void)callRequestAccessHandler;

@property (nonatomic, copy) NSArray* accountsToReturn;

@end
