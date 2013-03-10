//
//  XIGTwitterAccountCell.h
//  AppNetChecker
//
//  Created by Julien Grimault on 7/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface XIGTwitterAccountCell : UITableViewCell

@property (nonatomic, copy, readonly) NSString *displayedUsername;
- (void)bindAccont:(ACAccount *)account;
+ (CGFloat)rowHeight;
@end
