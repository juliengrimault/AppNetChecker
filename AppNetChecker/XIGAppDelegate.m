//
//  JGAAppDelegate.m
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGAppDelegate.h"
#import "XIGSemiModalController.h"
#import "XIGAccountPickerViewController.h"
#import "UIStoryboard+AppNetChecker.h"
#import "XIGHelpViewController.h"

@implementation XIGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureAppearance];
    [self setupViewControllerHierarchy];
    return YES;
}

- (void)setupViewControllerHierarchy {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    XIGAccountPickerViewController *accountPickerViewController = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"XIGAccountPickerViewController"];
    XIGHelpViewController *helpViewController = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"XIGHelpViewController"];
    XIGSemiModalController *semiModalController = [[XIGSemiModalController alloc] initWithFrontViewController:helpViewController
                                                                                           backViewController:accountPickerViewController];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:semiModalController];
    semiModalController.open = YES;

    [RACAble(semiModalController, open) subscribeNext:^(id x) {
       [navigationController setNavigationBarHidden:![x boolValue] animated:YES];
    }];
    self.window.rootViewController = navigationController;
}

- (void)configureAppearance {
    UIImage *navBarImage = [UIImage imageNamed:@"NavigationBar.png"];
    [[UINavigationBar appearance] setBackgroundImage:[navBarImage resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 0, 8)]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{ UITextAttributeFont : [UIFont xig_regularFontOfSize:24]}];
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:-5 forBarMetrics:UIBarMetricsDefault];

    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"ToolBar.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"empty.png"]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -50) forBarMetrics:UIBarMetricsDefault];
}

@end
