//
//  ACAccount+XIGTest.m
//  AppNetChecker
//
//  Created by Julien Grimault on 12/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "ACAccount+XIGTest.h"

@implementation ACAccount (XIGTest)
+(instancetype)testAccount
{
    ACAccountStore* store = [[ACAccountStore alloc] init];
    ACAccountType* type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccount* account = [[ACAccount alloc] initWithAccountType:type];
    ACAccountCredential* credentials = [[ACAccountCredential alloc] initWithOAuthToken:@"123123" tokenSecret:@"123123"];
    account.credential = credentials;
    account.username = @"testUser";
    
    return account;
}
@end
