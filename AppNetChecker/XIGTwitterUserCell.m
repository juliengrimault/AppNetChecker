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
    self.statusLabel.text = nil;
    self.appNetTitle.text = NSLocalizedString(@"searching...", nil);
    self.appNetSubTitle.text = nil;
}

- (void)dealloc
{
    [self.profileImageView cancelImageRequestOperation];
    [self.disposable dispose];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor xig_tableviewCellBackgroundColor];
    self.usernameLabel.font = [UIFont xig_regularFontOfSize:self.usernameLabel.font.pointSize];
    self.appNetTitle.font = [UIFont xig_regularFontOfSize:self.appNetTitle.font.pointSize];
    self.appNetSubTitle.font = [UIFont xig_regularFontOfSize:self.appNetSubTitle.font.pointSize];
    self.statusLabel.font = [UIFont xig_iconFontWithSize:self.statusLabel.font.pointSize];
}

- (void)bindUserMatcher:(XIGUserMatcher *)userMatcher
{
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@",[userMatcher.twitterUser.screenName uppercaseString]];
    [self.profileImageView setImageWithURL:userMatcher.twitterUser.profileImageURL];
    
    @weakify(self);
    self.disposable = [userMatcher.appNetUser subscribeNext:^(XIGAppNetUser *appNetUser) {
        @strongify(self);
        [self.activityIndicator stopAnimating];
        if (appNetUser != nil) {
            self.appNetTitle.text = NSLocalizedString(@"1,234 Posts", nil);
            self.appNetSubTitle.text = NSLocalizedString(@"230 Followers", nil);
            self.statusLabel.text = @"\U0000e010";
            self.statusLabel.textColor = [UIColor xig_greenColor];
        } else {
            self.appNetTitle.text = NSLocalizedString(@"User Not Found", nil);
            self.appNetSubTitle.text = NSLocalizedString(@"=(", nil);
            self.statusLabel.text = @"\U0000e00d";
            self.statusLabel.textColor = [UIColor xig_redColor];
        }
    }];
}

+ (CGFloat)rowHeight
{
    return 100;
}

@end
