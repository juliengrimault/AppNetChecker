//
//  XIGTwitterUserCell.m
//  AppNetChecker
//
//  Created by Julien Grimault on 24/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterUserCell.h"
#import "XIGTwitterUser.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation XIGTwitterUserCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.profileImageView cancelImageRequestOperation];
}

- (void)dealloc
{
    [self.profileImageView cancelImageRequestOperation];
}

- (void)bindUser:(XIGTwitterUser *)user
{
    self.usernameLabel.text = user.screenName;
    self.fullnameLabel.text = user.name;
    [self.profileImageView setImageWithURL:user.profileImageURL];
}

@end
