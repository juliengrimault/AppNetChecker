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
@class XIGAppNetClient;
@interface XIGUserMatcher : NSObject

@property (nonatomic, readonly, strong) XIGTwitterUser *twitterUser;
@property (nonatomic, readonly) XIGAppNetUser *appNetUser;
@property (atomic, readonly, getter = hasFinishedCheckingAppNet) BOOL finishedCheckingAppNet;//atomic on purpose

- (instancetype)initWithTwitterUser:(XIGTwitterUser *)twitterUser appNetClient:(XIGAppNetClient *)client;

@end
