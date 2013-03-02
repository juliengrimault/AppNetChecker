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
@property (nonatomic, strong) RACDisposable* disposable1;
@property (nonatomic, strong) RACDisposable* disposable2;

@end
@implementation XIGTwitterUserCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.profileImageView cancelImageRequestOperation];
    self.imageView.hidden = YES;
    [self.activityIndicator startAnimating];
    [self.disposable1 dispose];
    [self.disposable2 dispose];
}

- (void)dealloc
{
    [self.profileImageView cancelImageRequestOperation];
    [self.disposable1 dispose];
    [self.disposable2 dispose];
}

- (void)bindUserMatcher:(XIGUserMatcher *)userMatcher
{
    self.usernameLabel.text = userMatcher.twitterUser.screenName;
    self.fullnameLabel.text = userMatcher.twitterUser.name;
    [self.profileImageView setImageWithURL:userMatcher.twitterUser.profileImageURL];
    
    @weakify(self);
    self.disposable1 = [RACAbleWithStart(userMatcher, finishedCheckingAppNet) subscribeNext:^(id finished) {
        @strongify(self);
        if ([finished boolValue]) {
            [self.activityIndicator stopAnimating];
        }
        self.statusImageView.hidden = ![finished boolValue];
    }];
    
    self.disposable2 = [RACAbleWithStart(userMatcher, appNetUser) subscribeNext:^(id newuser) {
        @strongify(self);
        UIImage* image = newuser != nil ? [UIImage imageNamed:@"valid.png"] : [UIImage imageNamed:@"invalid.png"];
        self.statusImageView.image = image;
    }];
}

@end
