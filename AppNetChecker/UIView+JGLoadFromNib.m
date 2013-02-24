//
//  UIView+JGLoadFromNib.m
//  TradeHero
//
//  Created by Julien Grimault on 17/4/12.
//  Copyright (c) 2012 julien.grimault@me.com. All rights reserved.
//

#import "UIView+JGLoadFromNib.h"

@implementation UIView (JGLoadFromNib)

+ (id) loadInstanceFromNib
{
    return [self loadInstanceFromNibNamed:NSStringFromClass([self class])];
}

+ (id) loadInstanceFromNibNamed:(NSString*)nibName
{
    UIView *result = nil;
    NSArray *elements = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    for (id anObject in elements)
    {
        if ([anObject isKindOfClass:[self class]])
        {
            result = anObject;
            break;
        }
    }
    return result;
}


@end
