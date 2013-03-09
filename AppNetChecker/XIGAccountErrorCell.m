//
//  XIGAccountErrorCell.m
//  AppNetChecker
//
//  Created by Julien Grimault on 11/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGAccountErrorCell.h"
#import <Accounts/Accounts.h>

@implementation XIGAccountErrorCell

#pragma mark - Binding Error
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.errorLabel.font = [UIFont xig_regularFontOfSize:self.errorLabel.font.pointSize];
}
- (void)bindError:(NSError*)error
{
    self.errorLabel.text = [self messageForError:error];
}

- (NSString*)messageForError:(NSError*)error
{
    if (![error.domain isEqualToString:ACErrorDomain])
        return [self genericErrorMessage];
    
    switch (error.code) {
        case ACErrorAccountNotFound:
            return NSLocalizedString(@"No Twitter account was found on your device.", nil);;
            
        case ACErrorAccessNotGranted:
            return NSLocalizedString(@"Enable Twitter access for App.NetChecker from your device's Settings > Twitter", nil);
            
        default:
            return [self genericErrorMessage];
    }
}

- (NSString*)genericErrorMessage
{
    return NSLocalizedString(@"An error has occurred. Please try again later.", nil);
}

+(CGFloat)rowHeight
{
    return 300;
}

@end