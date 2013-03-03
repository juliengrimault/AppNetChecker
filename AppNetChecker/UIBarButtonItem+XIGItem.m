//
//  UIBarButtonItem+XIGItem.m
//  AppNetChecker
//
//  Created by Julien Grimault on 3/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "UIBarButtonItem+XIGItem.h"

@implementation UIBarButtonItem (XIGItem)

+ (UIBarButtonItem *)loadingIndicatorBarButtonItemWithStyle:(UIActivityIndicatorViewStyle)style
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    [indicator startAnimating];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    return item;
}
@end
