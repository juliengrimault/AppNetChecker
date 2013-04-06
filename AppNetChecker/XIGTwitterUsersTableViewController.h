//
//  XIGTwitterUsersTableViewController.h
//  AppNetChecker
//
//  Created by Julien Grimault on 24/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XIGTableViewController.h"
@class XIGTwitAppClient;
@class XIGUserMatchersToolbar;

@interface XIGTwitterUsersTableViewController : XIGTableViewController {
}

//Must be set before presenting this controller
@property (nonatomic, strong) XIGTwitAppClient *twittAppClient;
@property (nonatomic, strong, readonly) XIGUserMatchersToolbar *toolbarHelper;
@property (nonatomic, strong) NSMutableArray* userMatchers;

@end
