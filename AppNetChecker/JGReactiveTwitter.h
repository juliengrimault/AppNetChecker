//
//  JGReactiveTwitter.h
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Accounts/Accounts.h>

@interface JGReactiveTwitter : NSObject

@property (nonatomic, strong) ACAccountStore* accountStore;

- (RACSignal*)twitterAccountSignal;

@end
