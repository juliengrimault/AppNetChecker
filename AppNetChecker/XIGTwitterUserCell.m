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
    self.accessoryType = UITableViewCellAccessoryNone;
    [self.activityIndicator startAnimating];
    [self.disposable dispose];
}

- (void)dealloc
{
    [self.profileImageView cancelImageRequestOperation];
    [self.disposable dispose];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.usernameLabel.font = [UIFont xig_lightFontOfSize:self.usernameLabel.font.pointSize];
    self.fullnameLabel.font = [UIFont xig_thinFontOfSize:self.fullnameLabel.font.pointSize];
}

- (void)bindUserMatcher:(XIGUserMatcher *)userMatcher
{
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@",[userMatcher.twitterUser.screenName uppercaseString]];
    self.fullnameLabel.text = userMatcher.twitterUser.name;
    [self.profileImageView setImageWithURL:userMatcher.twitterUser.profileImageURL];
    
    @weakify(self);
    self.disposable = [userMatcher.appNetUser subscribeNext:^(XIGAppNetUser *appNetUser) {
        @strongify(self);
        [self.activityIndicator stopAnimating];
        if (appNetUser != nil) {
            self.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }];
}

+ (CGFloat)rowHeight
{
    return 90;
}

@end
