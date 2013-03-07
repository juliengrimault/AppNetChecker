//
//  XIGTwitterAccountCell.m
//  AppNetChecker
//
//  Created by Julien Grimault on 7/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterAccountCell.h"

@implementation XIGTwitterAccountCell

- (void)bindAccont:(ACAccount *)account
{
    self.accountNameLabel.text = [account.username uppercaseString];
}

+ (CGFloat)rowHeight
{
    return 70;
}
@end
