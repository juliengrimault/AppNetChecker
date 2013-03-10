//
//  UIColor+XIGAppNetChecker.m
//  AppNetChecker
//
//  Created by Julien Grimault on 9/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "UIColor+XIGAppNetChecker.h"

@implementation UIColor (XIGAppNetChecker)

+ (UIColor *)xig_tableViewBackgroundColor
{
    return [UIColor colorWithWhite:0.149 alpha:1];
}

+ (UIColor *)xig_tableviewCellBackgroundColor
{
    return [UIColor colorWithRed: 0.208 green: 0.286 blue: 0.365 alpha: 0.45];
}

+ (instancetype) xig_redColor
{
    return [UIColor colorWithRed:0.75 green:0.22 blue:0.17 alpha:1.0];
}

+ (instancetype) xig_greenColor
{
    return [UIColor colorWithRed:0.09 green:0.63 blue:0.52 alpha:1.0];
}

@end
