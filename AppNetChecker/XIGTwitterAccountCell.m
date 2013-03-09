//
//  XIGTwitterAccountCell.m
//  AppNetChecker
//
//  Created by Julien Grimault on 7/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterAccountCell.h"

@interface XIGTwitterAccountCell ()
@property (nonatomic, copy) NSString *accountName;
@end
@implementation XIGTwitterAccountCell

- (void)bindAccont:(ACAccount *)account
{
    self.accountName = [NSString stringWithFormat:@"@%@",[account.username uppercaseString]];
    [self setNeedsDisplay];
}

+ (CGFloat)rowHeight
{
    return 70;
}

- (void)drawRect:(CGRect)frame
{
    //// Color Declarations
    UIColor* backgroundColor = [UIColor colorWithRed: 0.208 green: 0.286 blue: 0.365 alpha: 1];
    UIColor* transparantBackgroundColor = [backgroundColor colorWithAlphaComponent: 0.45];
    UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Abstracted Attributes
    NSString* disclosureIndicatorContent = @">";
    UIFont* disclosureIndicatorFont = [UIFont xig_lightFontOfSize: 31];
    NSString* twitterAccountLabelContent = self.accountName;
    UIFont* twitterAccountLabelFont = [UIFont xig_regularFontOfSize:31];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame))];
    [transparantBackgroundColor setFill];
    [rectanglePath fill];
    
    
    //// disclosureIndicator Drawing
    CGRect disclosureIndicatorRect = CGRectMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) - 27, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 40) * 0.46667 + 0.5), 27, 40);
    [fillColor setFill];
    [disclosureIndicatorContent drawInRect: disclosureIndicatorRect withFont: disclosureIndicatorFont lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
    
    
    //// twitterAccountLabel Drawing
    CGRect twitterAccountLabelRect = CGRectMake(CGRectGetMinX(frame) + 22, CGRectGetMinY(frame) + floor((CGRectGetHeight(frame) - 40) * 0.46667 + 0.5), floor((CGRectGetWidth(frame) - 22) * 0.75168 + 0.5), 40);
    [fillColor setFill];
    [twitterAccountLabelContent drawInRect: twitterAccountLabelRect withFont: twitterAccountLabelFont lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentLeft];

}
@end
