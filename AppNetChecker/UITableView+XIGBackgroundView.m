//
//  UITableView+XIGBackgroundView.m
//  AppNetChecker
//
//  Created by Julien Grimault on 9/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "UITableView+XIGBackgroundView.h"

@implementation UITableView (XIGBackgroundView)

- (void)xig_configureBackgroundView
{
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = [UIColor xig_tableViewBackgroundColor];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    [view addSubview:logoImageView];
    logoImageView.center = view.center;
    logoImageView.contentMode = UIViewContentModeCenter;
    logoImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.backgroundView = view;
}
@end
