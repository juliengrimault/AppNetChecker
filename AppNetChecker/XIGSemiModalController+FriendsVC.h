//
//  XIGSemiModalController+FriendsVC.h
//  AppNetChecker
//
//  Created by Julien Grimault on 1/5/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGSemiModalController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface XIGSemiModalController (FriendsVC)

+ (instancetype)friendsVCWithUserMatcherSignal:(RACSignal *)signal;
@end
