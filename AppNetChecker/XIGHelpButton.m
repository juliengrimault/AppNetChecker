//
// Created by julien on 18/3/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "XIGHelpButton.h"

@implementation XIGHelpButton {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect {
    //// Color Declarations
    UIColor* backgroundColor = self.backgroundColor;
    UIColor* messageColor = self.titleColor;


//// Frames
    CGRect frame = rect;

//// Abstracted Attributes
    NSString* textContent = self.title;
    NSString* questionMarkContent = @"?";


//// Background Drawing
    UIBezierPath* backgroundPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame))];
    [backgroundColor setFill];
    [backgroundPath fill];


//// Text Drawing
    CGRect textRect = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + 8, CGRectGetWidth(frame) - 46, CGRectGetHeight(frame) - 17);
    [messageColor setFill];
    [textContent drawInRect: textRect withFont:self.font lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];


//// QuestionMarkIcon
    {
        //// questionMark Drawing
        CGRect questionMarkRect = CGRectMake(CGRectGetMinX(frame) + 274, CGRectGetMinY(frame) + 3, 30, 30);
        [messageColor setFill];
        [questionMarkContent drawInRect: questionMarkRect withFont: [UIFont fontWithName: @"YanoneKaffeesatz-Regular" size: 30] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];


        //// topIcon Drawing
        UIBezierPath* topIconPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 274, CGRectGetMinY(frame) + 6, 30, 2)];
        [messageColor setFill];
        [topIconPath fill];


        //// bottomIcon Drawing
        UIBezierPath* bottomIconPath = [UIBezierPath bezierPathWithRect: CGRectMake(CGRectGetMinX(frame) + 274, CGRectGetMinY(frame) + 36, 30, 2)];
        [messageColor setFill];
        [bottomIconPath fill];
    }
}

@end