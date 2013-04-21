//
// Created by julien on 17/3/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreGraphics/CoreGraphics.h>
#import "XIGSemiModalController.h"

static CGFloat const kDefaultOpenedBottomOffset = 44;
static CGFloat const kDefaultClosedTopOffset = 0;
static CGFloat const kPanThresholdMultiplier = 0.2;

@interface  XIGSemiModalController()
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation XIGSemiModalController {
}
#pragma mark - Init
- (id)initWithFrontViewController:(UIViewController *)frontViewController backViewController:(UIViewController *)backViewController {
    self = [super init];
    if (self) {
        _openBottomOffset = kDefaultOpenedBottomOffset;
        _closedTopOffset = kDefaultClosedTopOffset;
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
    [current.view removeGestureRecognizer:self.panGestureRecognizer];

    if (new != nil) {
        [self addChildViewController:new];
        new.view.frame = self.view.frame;
        [new.view addGestureRecognizer:self.panGestureRecognizer];
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
    CGRect f = self.view.bounds;
    if (opened) {
        return CGRectOffset(f, 0, CGRectGetHeight(f) - self.openBottomOffset);
    } else {
        return CGRectOffset(f, 0, self.closedTopOffset);
    }
}

- (CGFloat)panThreshold {
    CGRect closeFrame = [self frontViewFrameForState:NO];
    CGRect openFrame = [self frontViewFrameForState:YES];
    return fabsf(closeFrame.origin.y - openFrame.origin.y) * kPanThresholdMultiplier;
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

#pragma mark - Pan Tracking
- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    }
    return _panGestureRecognizer;
}

- (void)didPan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGRect adjustedFrame = [self adjustedFrameForFrontView];
        self.frontViewController.view.frame = adjustedFrame;
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (fabsf([recognizer translationInView:recognizer.view].y) > [self panThreshold] ) {
            [self toggleOpenAnimated:YES];
        } else {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.frontViewController.view.frame = [self frontViewFrameForState:[self isOpen]];
                             }];
        }
    }
}

- (CGRect)adjustedFrameForFrontView {
    CGRect baseFrame = [self frontViewFrameForState:[self isOpen]];
    CGFloat deltaY = [self.panGestureRecognizer translationInView:self.panGestureRecognizer.view].y;
    CGRect pannedFrame = CGRectOffset(baseFrame, 0, deltaY);
    if (pannedFrame.origin.y < 0) {
        pannedFrame.origin.y = 0;
    } else if (pannedFrame.origin.y > (CGRectGetHeight(self.view.frame) - self.openBottomOffset)) {
        pannedFrame.origin.y = CGRectGetHeight(self.view.frame) - self.openBottomOffset;
    }
    return pannedFrame;
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