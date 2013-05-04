//
//  XIGTwitterUserCell.h
//  AppNetChecker
//
//  Created by Julien Grimault on 24/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XIGUserMatcher;
@interface XIGTwitterUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *appNetTitle;
@property (weak, nonatomic) IBOutlet UILabel *appNetSubTitle;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (void)bindUserMatcher:(XIGUserMatcher *)userMatcher;

+ (CGFloat)rowHeight;
@end
