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
@interface XIGTwitterUsersTableViewController : XIGTableViewController {
    UIActivityIndicatorView *_appNetLoadingIndicator;
}

//Must be set before presenting this controller
@property (nonatomic, strong) XIGTwitAppClient *twittAppClient;

@property (nonatomic, readonly) UIActivityIndicatorView *twitterLoadingIndicator;
@property(nonatomic, strong) UIActivityIndicatorView *appNetLoadingIndicator;

@property (nonatomic, readonly) UILabel *friendsCountLabel;
@property (nonatomic, readonly) UILabel *friendsFoundCountLabel;

@property (nonatomic, strong) NSMutableArray* userMatchers;

@end
