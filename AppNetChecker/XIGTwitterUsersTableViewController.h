//
//  XIGTwitterUsersTableViewController.h
//  AppNetChecker
//
//  Created by Julien Grimault on 24/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XIGTableViewController.h"
#import "XIGUserFilterViewController.h"
@class XIGTwitAppClient;
@class XIGUserMatchersToolbar;

@interface XIGTwitterUsersTableViewController : JGTableViewController {
}

@property (nonatomic) XIGUserFilter filter;

@property (nonatomic, strong) NSMutableArray* userMatchers;

- (instancetype)initWithUserMatchersSignal:(RACSignal *)userMatcherSignal;

@end
