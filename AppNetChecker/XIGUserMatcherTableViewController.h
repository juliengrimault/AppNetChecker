//
//  XIGTwitterUsersTableViewController.h
//  AppNetChecker
//
//  Created by Julien Grimault on 24/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XIGTableViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface XIGUserMatcherTableViewController : JGTableViewController {
}
@property (nonatomic, strong, readonly) RACSignal *userMatchersSignal;
@property (nonatomic, strong, readonly) NSMutableArray* userMatchers;

- (instancetype)initWithUserMatchersSignal:(RACSignal *)userMatcherSignal;

@end
