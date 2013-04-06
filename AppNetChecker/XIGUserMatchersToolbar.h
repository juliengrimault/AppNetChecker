//
// Created by julien on 6/4/13.
//
//


#import <Foundation/Foundation.h>


@interface XIGUserMatchersToolbar : NSObject

@property (nonatomic, readonly, strong) NSArray *toolbarItems;

@property (nonatomic, readonly, strong) UIActivityIndicatorView *twitterLoadingIndicator;
@property (nonatomic, readonly, strong) UILabel *friendsCountLabel;
@property (nonatomic, readonly, strong) UILabel *friendsFoundCountLabel;
@property (nonatomic, readonly, strong) UIActivityIndicatorView *appNetLoadingIndicator;

@end