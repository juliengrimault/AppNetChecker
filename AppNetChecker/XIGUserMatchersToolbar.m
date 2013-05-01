//
// Created by julien on 6/4/13.
//
//


#import "UIBarButtonItem+XIGItem.h"
#import "XIGUserMatcherTableViewController.h"
#import "XIGUserMatchersToolbar.h"


@interface XIGUserMatchersToolbar()
@end

@implementation XIGUserMatchersToolbar

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [self commonInit];
}

- (void)commonInit {
    [self configureFriendCountLabel];
    [self configureFriendFoundCountLabel];
    self.backgroundColor = [UIColor xig_toolbarColor];
}

    - (void)configureFriendCountLabel {
        _friendsCountLabel.text = nil;
        _friendsCountLabel.backgroundColor = [UIColor clearColor];
        _friendsCountLabel.textColor = [UIColor whiteColor];
        _friendsCountLabel.font = [UIFont xig_thinFontOfSize:[UIFont labelFontSize]];
    }

    - (void)configureFriendFoundCountLabel {
        _friendsFoundCountLabel.text = nil;
        _friendsFoundCountLabel.backgroundColor = [UIColor clearColor];
        _friendsFoundCountLabel.textColor = [UIColor whiteColor];
        _friendsFoundCountLabel.font = [UIFont xig_thinFontOfSize:[UIFont labelFontSize]];
        _friendsFoundCountLabel.textAlignment = NSTextAlignmentRight;
    }

@end