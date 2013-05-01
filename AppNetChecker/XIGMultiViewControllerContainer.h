//
//  XIGMultiViewControllerContainer.h
//  AppNetChecker
//
//  Created by Julien Grimault on 1/5/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XIGMultiViewControllerContainer : UIViewController

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, readonly) UIViewController *selectedViewController;

- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

@end
