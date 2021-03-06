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
#import "NSString+InflectorKit.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

static NSNumberFormatter *_decimalFormatter;

@interface XIGTwitterUserCell()
@end

@implementation XIGTwitterUserCell

+ (NSNumberFormatter *)decimalFormatter {
    if (_decimalFormatter == nil) {
        _decimalFormatter = [[NSNumberFormatter alloc] init];
        _decimalFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    return _decimalFormatter;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.profileImageView cancelImageRequestOperation];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.statusLabel.text = nil;
    self.appNetTitle.text = nil;
    self.appNetSubTitle.text = nil;
}

- (void)dealloc
{
    [self.profileImageView cancelImageRequestOperation];
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
    [self.profileImageView setImageWithURL:userMatcher.twitterUser.profileImageURL placeholderImage:[UIImage imageNamed:@"default-avatar.png"]];

    if (userMatcher.appNetUser != nil) {
        NSNumberFormatter *formatter = [[self class] decimalFormatter];
        self.appNetTitle.text = [NSString localizedStringWithFormat:@"%@ Following", [formatter stringFromNumber:userMatcher.appNetUser.followingCount]];
        NSString *followers = @"Follower";
        if ([userMatcher.appNetUser.followerCount integerValue]  > 0) {
            followers = [followers pluralizedString];
        }
        self.appNetSubTitle.text = [NSString localizedStringWithFormat:@"%@ %@", [formatter stringFromNumber:userMatcher.appNetUser.followerCount], followers];
        self.statusLabel.text = @"\U0000e010";
        self.statusLabel.textColor = [UIColor xig_greenColor];
    } else {
        self.appNetTitle.text = NSLocalizedString(@"User Not Found", nil);
        self.appNetSubTitle.text = nil;
        self.statusLabel.text = @"\U0000e00d";
        self.statusLabel.textColor = [UIColor xig_redColor];
    }
}

+ (CGFloat)rowHeight
{
    return 100;
}

@end
