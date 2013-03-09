//
//  XIGTableViewController.m
//  AppNetChecker
//
//  Created by Julien Grimault on 9/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTableViewController.h"
#import "UITableView+XIGBackgroundView.h"

@interface XIGTableViewController ()

@end

@implementation XIGTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView xig_configureBackgroundView];
}
@end
