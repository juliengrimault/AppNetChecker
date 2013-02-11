//
//  SLComposeViewController+Hack.h
//  AppNetChecker
//
//  Created by Julien Grimault on 11/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Social/Social.h>

@interface UIViewController(SLServiceHack)

- (void)presentRegisterServiceViewControllerWithServiceType:(NSString*)type;

@end

