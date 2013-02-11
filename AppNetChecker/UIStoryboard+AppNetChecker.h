//
//  UIStoryboard+AppNetChecker.h
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (AppNetChecker)

+ (instancetype)mainStoryboard;
- (id)instantiateViewControllerOfClass:(Class)klass;

@end
