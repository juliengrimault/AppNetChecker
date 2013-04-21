//
// Created by julien on 17/3/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface XIGSemiModalController : UIViewController

@property (nonatomic, strong) UIViewController *backViewController;
@property (nonatomic, strong) UIViewController *frontViewController;

@property (nonatomic) CGFloat closedTopOffset;
@property (nonatomic) CGFloat openBottomOffset;

@property (nonatomic, getter=isOpen) BOOL open;
- (void)toggleOpenAnimated:(BOOL)animated;
- (void)setOpen:(BOOL)open animated:(BOOL)animated;

- (id)initWithFrontViewController:(UIViewController *)frontViewController backViewController:(UIViewController *)backViewController;
@end


@interface UIViewController (XIGSemiModalController)
@property (nonatomic, readonly) XIGSemiModalController *semiModalController;
@end