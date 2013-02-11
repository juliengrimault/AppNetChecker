//
//  UIStoryboard+AppNetChecker.m
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "UIStoryboard+AppNetChecker.h"

@implementation UIStoryboard (AppNetChecker)

+ (instancetype)mainStoryboard;
{
    return [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
}

- (id)instantiateViewControllerOfClass:(Class)klass
{
    return [self instantiateViewControllerWithIdentifier:NSStringFromClass(klass)];
}

@end
