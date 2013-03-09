//
//  UIFont+XIGAppNetChecker.m
//  AppNetChecker
//
//  Created by Julien Grimault on 9/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "UIFont+XIGAppNetChecker.h"

@implementation UIFont (XIGAppNetChecker)

+ (instancetype) xig_regularFontOfSize:(CGFloat)pointSize
{
    return [UIFont fontWithName:@"YanoneKaffeesatz-Regular" size:pointSize];
}

+ (instancetype) xig_thinFontOfSize:(CGFloat)pointSize
{
    return [UIFont fontWithName:@"YanoneKaffeesatz-Thin" size:pointSize];
}

+ (instancetype) xig_lightFontOfSize:(CGFloat)pointSize
{
    return [UIFont fontWithName:@"YanoneKaffeesatz-Light" size:pointSize];
}

+ (instancetype) xig_boldFontOfSize:(CGFloat)pointSize
{
    return [UIFont fontWithName:@"YanoneKaffeesatz-Bold" size:pointSize];
}


@end
