//
//  XIGTwitterUsersTableViewController.h
//  AppNetChecker
//
//  Created by Julien Grimault on 24/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XIGTwitterClient;

@interface XIGTwitterUsersTableViewController : UITableViewController

@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, readonly) UILabel *friendsCountLabel;

//lazyly loaded
@property (nonatomic, strong) XIGTwitterClient *twitterClient;
@property (nonatomic, readonly) NSArray *friends;

@end