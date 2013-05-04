//
//  JGAAppDelegate.m
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGAppDelegate.h"
#import "XIGAppDelegate+Reporting.h"
#import "XIGSemiModalController.h"
#import "XIGAccountPickerViewController.h"
#import "UIStoryboard+AppNetChecker.h"
#import "XIGHelpViewController.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation XIGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureAppearance];
    [self setupViewControllerHierarchy];
    [self setupLoggers];
    [self setupCrashReporter];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    return YES;
}

- (void)setupViewControllerHierarchy {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    XIGAccountPickerViewController *accountPickerViewController = [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"XIGAccountPickerViewController"];
    XIGHelpViewController *helpViewController = [[XIGHelpViewController alloc] init];
    XIGSemiModalController *semiModalController = [[XIGSemiModalController alloc] initWithFrontViewController:helpViewController
                                                                                           backViewController:accountPickerViewController];
    UINavigationController*navigationController = [[UINavigationController alloc] initWithRootViewController:semiModalController];
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

    UIImage *backButtonBackground = [[UIImage imageNamed:@"BackArrow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 1)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonBackground
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -50) forBarMetrics:UIBarMetricsDefault];
}

@end
