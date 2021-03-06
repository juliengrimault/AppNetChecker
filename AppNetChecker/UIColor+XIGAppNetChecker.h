//
//  UIColor+XIGAppNetChecker.h
//  AppNetChecker
//
//  Created by Julien Grimault on 9/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (XIGAppNetChecker)

+ (UIColor *)xig_tableViewBackgroundColor;
+ (UIColor *)xig_tableviewCellBackgroundColor;

+ (instancetype) xig_redColor;
+ (instancetype) xig_greenColor;

+ (instancetype) xig_toolbarColor;
@end
