//
// Created by julien on 6/4/13.
//
//


#import "UIBarButtonItem+XIGItem.h"
#import "XIGTwitterUsersTableViewController.h"
#import "XIGUserMatchersToolbar.h"


@interface XIGUserMatchersToolbar()
@property (nonatomic, strong) NSArray *toolbarItems;
@end

@implementation XIGUserMatchersToolbar

- (id)init {
    self = [super init];
    if (self) {
        UIBarButtonItem *twitterLoadingItem= [self createTwitterLoadingButtonItem];
        UIBarButtonItem *friendCountItem = [self createFriendCountItem];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *friendFoundCountItem = [self createFriendFoundCountItem];
        UIBarButtonItem *appNetLoadingItem= [self createAppNetLoadingItem];
        self.toolbarItems = @[twitterLoadingItem, friendCountItem, spaceItem, friendFoundCountItem, appNetLoadingItem];
    }
    return self;
}

- (UIBarButtonItem *)createTwitterLoadingButtonItem {
    UIBarButtonItem *twitterLoadingItem = [UIBarButtonItem loadingIndicatorBarButtonItemWithStyle:UIActivityIndicatorViewStyleWhite];
    _twitterLoadingIndicator = (UIActivityIndicatorView*) twitterLoadingItem.customView;
    return twitterLoadingItem;
}

- (UIBarButtonItem *)createFriendCountItem {
    UILabel *friendsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    friendsCountLabel.backgroundColor = [UIColor clearColor];
    friendsCountLabel.textColor = [UIColor whiteColor];
    friendsCountLabel.font = [UIFont xig_thinFontOfSize:[UIFont labelFontSize]];
    _friendsCountLabel = friendsCountLabel;
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:friendsCountLabel];
    return item2;
}

- (UIBarButtonItem *)createFriendFoundCountItem {
    UILabel *friendsFoundCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    friendsFoundCountLabel.backgroundColor = [UIColor clearColor];
    friendsFoundCountLabel.textColor = [UIColor whiteColor];
    friendsFoundCountLabel.font = [UIFont xig_thinFontOfSize:[UIFont labelFontSize]];
    _friendsFoundCountLabel = friendsFoundCountLabel;
    _friendsFoundCountLabel.textAlignment = NSTextAlignmentRight;
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithCustomView:friendsFoundCountLabel];
    return item4;
}

- (UIBarButtonItem *)createAppNetLoadingItem {
    UIBarButtonItem *appNetLoadingItem = [UIBarButtonItem loadingIndicatorBarButtonItemWithStyle:UIActivityIndicatorViewStyleWhite];
    _appNetLoadingIndicator = (UIActivityIndicatorView*) appNetLoadingItem.customView;
    return appNetLoadingItem;
}
@end