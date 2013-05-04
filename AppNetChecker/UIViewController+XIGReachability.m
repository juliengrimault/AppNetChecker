//
//  UIViewController+XIGReachability.m
//  AppNetChecker
//
//  Created by Julien Grimault on 4/5/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "UIViewController+XIGReachability.h"
#import <AFNetworking/AFNetworking.h>
#import <TSMessages/TSMessage.h>

@implementation UIViewController (XIGReachability)

- (void)subscribeToReachabilityChanges {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
}

- (void)unsubscribeToReachabilityChanges {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AFNetworkingReachabilityDidChangeNotification
                                                  object:nil];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    NSNumber *s = notification.userInfo[AFNetworkingReachabilityNotificationStatusItem];
    AFNetworkReachabilityStatus status = [s integerValue];
    
    if (status == AFNetworkReachabilityStatusNotReachable) {
        [self showInternetError];
    }
}

- (void)showInternetError {
    [TSMessage showNotificationInViewController:self
                                      withTitle:NSLocalizedString(@"Network error", nil)
                                    withMessage:NSLocalizedString(@"Couldn't connect to the server. Check your network connection.", nil)
                                       withType:TSMessageNotificationTypeError];
}

@end
