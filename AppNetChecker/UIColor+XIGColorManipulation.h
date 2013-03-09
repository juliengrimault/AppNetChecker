//
//  UIColor+XIGColorManipulation.h
//  AppNetChecker
//
//  Created by Julien Grimault on 9/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (XIGColorManipulation)

- (UIColor *)hightlightedColor:(CGFloat)highlightPercentage;
- (UIColor *)darkenedColor:(CGFloat)darkenPercentage;
@end
