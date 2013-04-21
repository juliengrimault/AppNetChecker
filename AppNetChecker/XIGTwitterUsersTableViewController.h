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

//Must be set before presenting this controller
@property (nonatomic, strong) XIGTwitAppClient *twittAppClient;

@property (nonatomic) XIGUserFilter filter;

@property (nonatomic, strong) NSMutableArray* userMatchers;

@end
