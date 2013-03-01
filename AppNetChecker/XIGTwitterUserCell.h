//
//  XIGTwitterUserCell.h
//  AppNetChecker
//
//  Created by Julien Grimault on 24/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XIGTwitterUser;
@interface XIGTwitterUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullnameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

- (void)bindUser:(XIGTwitterUser *)user;
@end