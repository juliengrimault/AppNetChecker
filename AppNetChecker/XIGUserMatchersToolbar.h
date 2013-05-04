//
// Created by julien on 6/4/13.
//
//


#import <Foundation/Foundation.h>


@interface XIGUserMatchersToolbar : UIButton

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, weak) IBOutlet UILabel *friendsCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *friendsFoundCountLabel;

@end