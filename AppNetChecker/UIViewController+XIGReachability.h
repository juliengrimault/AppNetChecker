//
//  UIViewController+XIGReachability.h
//  AppNetChecker
//
//  Created by Julien Grimault on 4/5/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (XIGReachability)

- (void)subscribeToReachabilityChanges;
- (void)unsubscribeToReachabilityChanges;
@end
