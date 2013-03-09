//
//  UIFont+XIGAppNetChecker.h
//  AppNetChecker
//
//  Created by Julien Grimault on 9/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (XIGAppNetChecker)

+ (instancetype) xig_regularFontOfSize:(CGFloat)pointSize;
+ (instancetype) xig_thinFontOfSize:(CGFloat)pointSize;
+ (instancetype) xig_lightFontOfSize:(CGFloat)pointSize;
+ (instancetype) xig_boldFontOfSize:(CGFloat)pointSize;
@end
