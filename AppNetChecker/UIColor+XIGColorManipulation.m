//
//  UIColor+XIGColorManipulation.m
//  AppNetChecker
//
//  Created by Julien Grimault on 9/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "UIColor+XIGColorManipulation.h"

@implementation UIColor (XIGColorManipulation)

- (UIColor *)hightlightedColor:(CGFloat)highlightPercentage
{
    CGFloat rgba[4];
    [self getRed: &rgba[0] green: &rgba[1] blue: &rgba[2] alpha: &rgba[3]];
    CGFloat factor = 1.0 - highlightPercentage;
    UIColor* result = [UIColor colorWithRed: (rgba[0] * factor + highlightPercentage) green: (rgba[1] * factor + highlightPercentage) blue: (rgba[2] * factor + highlightPercentage) alpha: (rgba[3] * factor + highlightPercentage)];
    return result;
}

- (UIColor *)darkenedColor:(CGFloat)darkenPercentage
{
    CGFloat rgba[4];
    [self getRed: &rgba[0] green: &rgba[1] blue: &rgba[2] alpha: &rgba[3]];
    CGFloat factor = 1.0 - darkenPercentage;
    UIColor* result = [UIColor colorWithRed: (rgba[0] * factor) green: (rgba[1] * factor) blue: (rgba[2] * factor) alpha: (rgba[3] * factor + darkenPercentage)];
    return result;
}
@end
