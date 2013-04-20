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

typedef NS_ENUM(NSInteger , XIGUserMatchersFilter) {
  XIGUserMatcherAll = 0,
  XIGUserMatcherFound,
  XIGUserMatcherNotFound,
};

@interface XIGTwitterUsersTableViewController : JGTableViewController {
}

//Must be set before presenting this controller
@property (nonatomic, strong) XIGTwitAppClient *twittAppClient;

@property (nonatomic) XIGUserMatchersFilter filter;

@property (nonatomic, weak) IBOutlet XIGUserMatchersToolbar *userMatchersToolbar;
@property (nonatomic, strong) NSMutableArray* userMatchers;

@end
