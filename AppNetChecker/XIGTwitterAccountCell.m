//
//  XIGTwitterAccountCell.m
//  AppNetChecker
//
//  Created by Julien Grimault on 7/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterAccountCell.h"
#import "UIColor+XIGColorManipulation.h"
#import <QuartzCore/QuartzCore.h>

@interface XIGTwitterAccountCellView : UIView

@property (weak, nonatomic) XIGTwitterAccountCell *cell;

- (id)initWithFrame:(CGRect)frame twitterAccountCell:(XIGTwitterAccountCell *)cell;
@end

@interface XIGTwitterAccountCell ()
@property (nonatomic, strong) XIGTwitterAccountCellView *customView;
@property (nonatomic, copy) NSString *displayedUsername;
@end
@implementation XIGTwitterAccountCell
#pragma mark - Init
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.customView = [[XIGTwitterAccountCellView alloc] initWithFrame:self.contentView.frame twitterAccountCell:self];
    self.customView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.customView];
}

#pragma mark - Animation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (animated) {
        [self fadeOutCurrentContentView];
        [super setSelected:selected animated:NO];
    } else {
        [super setSelected:selected animated:NO];
    }
    [self.customView setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (animated) {
        [self fadeOutCurrentContentView];
        [super setHighlighted:highlighted animated:NO];
    } else {
        [super setHighlighted:highlighted animated:NO];
    }
    [self.customView setNeedsDisplay];
}

- (void)fadeOutCurrentContentView
{
    UIImage *i1 = [self grabScreenshot];
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:i1];
    imageView1.alpha = 1;
    [self.contentView addSubview:imageView1];
    [UIView animateWithDuration:0.5 animations:^{
        imageView1.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView1 removeFromSuperview];
    }];
}

- (UIImage *)grabScreenshot
{
    UIGraphicsBeginImageContext(self.contentView.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.contentView.layer renderInContext:ctx];
    UIImage* bitmap = UIGraphicsGetImageFromCurrentImageContext();
    return bitmap;
}

#pragma mark - Drawing

- (void)bindAccont:(ACAccount *)account
{
    self.displayedUsername = [NSString stringWithFormat:@"@%@",[account.username uppercaseString]];
    [self setNeedsDisplay];
}

+ (CGFloat)rowHeight
{
    return 70;
}

@end

@implementation XIGTwitterAccountCellView
- (id)initWithFrame:(CGRect)frame twitterAccountCell:(XIGTwitterAccountCell *)cell
{
    self = [super initWithFrame:frame];
    if (self) {
        _cell = cell;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)frame
{
    //// Color Declarations
    UIColor* transparantBackgroundColor = [UIColor xig_tableviewCellBackgroundColor];
    UIColor* fillColor = [UIColor colorWithWhite:1 alpha:1];
    UIColor* selectedBackgroundColor = [transparantBackgroundColor darkenedColor:0.5];

    //// Abstracted Attributes
    NSString* disclosureIndicatorContent = @">";
    UIFont* disclosureIndicatorFont = [UIFont xig_lightFontOfSize: 31];
    NSString* twitterAccountLabelContent = self.cell.displayedUsername;
    UIFont* twitterAccountLabelFont = [UIFont xig_regularFontOfSize:31];
    
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame))];
    if (self.cell.selected || self.cell.highlighted) {
        [selectedBackgroundColor setFill];
    } else {
         [transparantBackgroundColor setFill];
    }
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
