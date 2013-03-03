//
//  XIGTwitterUsersTableViewController.h
//  AppNetChecker
//
//  Created by Julien Grimault on 24/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XIGTwitterClient;
@class XIGAppNetClient;
@interface XIGTwitterUsersTableViewController : UITableViewController

@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, readonly) UILabel *friendsCountLabel;
@property (nonatomic, readonly) UILabel *friendsFoundCountLabel;

@property (nonatomic, strong) NSMutableArray* userMatchers;

//lazyly loaded
@property (nonatomic, strong) XIGTwitterClient *twitterClient;
@property (nonatomic, strong) XIGAppNetClient *appNetClient;

@end
