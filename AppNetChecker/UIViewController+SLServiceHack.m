//
//  SLComposeViewController+Hack.m
//  AppNetChecker
//
//  Created by Julien Grimault on 11/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "UIViewController+SLServiceHack.h"

@implementation UIViewController (ServiceHack)

- (void)presentRegisterServiceViewControllerWithServiceType:(NSString*)type
{
    SLComposeViewController* compose = [SLComposeViewController composeViewControllerForServiceType:type];
    compose.view.hidden = YES;
    [self presentViewController:compose animated:NO completion:^{
        [compose.view endEditing:YES];
    }];
}

@end
