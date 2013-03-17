//
// Created by julien on 17/3/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "XIGSemiModalController.h"

static CGFloat const kDefaultOpenedBottomOffset = 44;

@implementation XIGSemiModalController {
}

- (id)initWithFrontViewController:(UIViewController *)frontViewController backViewController:(UIViewController *)backViewController {
    self = [super init];
    if (self) {
        _openBottomOffset = kDefaultOpenedBottomOffset;
        _frontViewController = frontViewController;
        _backViewController = backViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeBackViewControllerFrom:nil to:_backViewController];
    [self changeFrontViewControllerFrom:nil to:_frontViewController];
}

#pragma mark - Back/Front View Controllers

- (void)setFrontViewController:(UIViewController *)frontViewController {
    if (frontViewController == _frontViewController) return;

    UIViewController *oldViewController = _frontViewController;
    _frontViewController = frontViewController;
    [self changeFrontViewControllerFrom:oldViewController to:frontViewController];
}

- (void)setBackViewController:(UIViewController *)backViewController {
    if (backViewController == _backViewController) return;

    UIViewController *oldViewController = _backViewController;
    _backViewController = backViewController;
    [self changeBackViewControllerFrom:oldViewController to:backViewController];
}

- (void)changeFrontViewControllerFrom:(UIViewController *)current to:(UIViewController *)new {
    [current willMoveToParentViewController:nil];
    [current.view removeFromSuperview];

    if (new != nil) {
        [self addChildViewController:new];
        new.view.frame = self.view.frame;
        [self.view addSubview:new.view];
    }
}

- (void)changeBackViewControllerFrom:(UIViewController *)current to:(UIViewController *)new {
    [current willMoveToParentViewController:nil];
    [current.view removeFromSuperview];

    if (new != nil) {
        [self addChildViewController:new];
        new.view.frame = self.view.frame;
        [self.view insertSubview:new.view atIndex:0];
    }
}

- (CGRect)frontViewFrameForState:(BOOL)opened {
    if (opened) {
        CGRect f = self.view.bounds;
        return CGRectOffset(f, 0, CGRectGetHeight(f) - self.openBottomOffset);
    } else {
        return self.view.bounds;
    }
}

#pragma mark - Open/Close state
- (void)setOpen:(BOOL)open {
    [self setOpen:open animated:NO];
}

- (void)setOpen:(BOOL)open animated:(BOOL)animated {
    [self willChangeValueForKey:@"open"];
    _open = open;
    [self didChangeValueForKey:@"open"];

    void (^updateFrame)() = ^{
      self.frontViewController.view.frame = [self frontViewFrameForState:_open];
    };

    if (animated) {
        [UIView animateWithDuration:0.3 animations:updateFrame];
    } else {
        updateFrame();
    }
}

- (void)toggleOpenAnimated:(BOOL)animated {
    [self setOpen:![self isOpen] animated:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.frontViewController.view.frame = [self frontViewFrameForState:[self isOpen]];
    self.backViewController.view.frame = self.view.bounds;
}

@end


@implementation UIViewController(XIGSemiModalController)
- (XIGSemiModalController *)semiModalController {
    UIViewController *controller = self;
    while (controller != nil) {
        if ([controller isKindOfClass:[XIGSemiModalController class]]) {
            return (XIGSemiModalController *)controller;
        }
        controller = controller.parentViewController;
    }
    return nil;
}
@end