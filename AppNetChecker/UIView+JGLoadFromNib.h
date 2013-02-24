//
//  UIView+JGLoadFromNib.h
//  TradeHero
//
//  Created by Julien Grimault on 17/4/12.
//  Copyright (c) 2012 julien.grimault@me.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JGLoadFromNib)
+ (id) loadInstanceFromNib;
+ (id) loadInstanceFromNibNamed:(NSString*)nibName;
@end
