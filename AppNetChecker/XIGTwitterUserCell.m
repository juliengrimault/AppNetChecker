//
//  XIGTwitterUserCell.m
//  AppNetChecker
//
//  Created by Julien Grimault on 24/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterUserCell.h"
#import "XIGUserMatcher.h"
#import "XIGTwitterUser.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface XIGTwitterUserCell()
@property (nonatomic, strong) RACDisposable* disposable;
@end

@implementation XIGTwitterUserCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.profileImageView cancelImageRequestOperation];
    self.statusImageView.hidden = YES;
    [self.activityIndicator startAnimating];
    [self.disposable dispose];
}

- (void)dealloc
{
    [self.profileImageView cancelImageRequestOperation];
    [self.disposable dispose];
}

- (void)bindUserMatcher:(XIGUserMatcher *)userMatcher
{
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@",userMatcher.twitterUser.screenName];
    self.fullnameLabel.text = userMatcher.twitterUser.name;
    [self.profileImageView setImageWithURL:userMatcher.twitterUser.profileImageURL];
    
    @weakify(self);
    self.disposable = [userMatcher.appNetUser subscribeNext:^(XIGAppNetUser *appNetUser) {
        @strongify(self);
        [self.activityIndicator stopAnimating];
        self.statusImageView.hidden = NO;
        UIImage* image = appNetUser != nil ? [UIImage imageNamed:@"valid.png"] : [UIImage imageNamed:@"invalid.png"];
        self.statusImageView.image = image;
    }];
}

@end
