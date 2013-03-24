//
//  XIGUserMatcher.h
//  AppNetChecker
//
//  Created by Julien Grimault on 2/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIGTwitterUser.h"
#import "XIGAppNetUser.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@class XIGAppNetClient;
@interface XIGUserMatcher : NSObject

@property (nonatomic, readonly, strong) XIGTwitterUser *twitterUser;
@property (nonatomic, readonly, strong) RACSignal *appNetUser;

- (instancetype)initWithTwitterUser:(XIGTwitterUser *)twitterUser appNetUserSignal:(RACSignal *)appNetUserSignal;

@end
