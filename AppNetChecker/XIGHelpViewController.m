//
// Created by julien on 17/3/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "XIGHelpViewController.h"
#import "XIGSemiModalController.h"
#import "RACBacktrace+Private.h"
#import <QuartzCore/QuartzCore.h>

@implementation XIGHelpViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureToggleButton];
    [self configureView];
}
#pragma mark - View Lifecycle
- (void)configureToggleButton {
    self.helpButton.backgroundColor = [UIColor colorWithRed: 0.133 green: 0.624 blue: 0.522 alpha: 1];
    self.helpButton.font = [UIFont xig_regularFontOfSize:20];
    self.helpButton.titleColor = [UIColor whiteColor];
    self.helpButton.title = NSLocalizedString(@"Find your Twitter friends on App.net", nil);
    [self.helpButton addTarget:self action:@selector(toggleButtonHandler:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)configureView {
    self.view.backgroundColor = [UIColor xig_tableViewBackgroundColor];
    self.textView.attributedText = [self helpText];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showHelpOnFirstLaunch];
}

- (void)showHelpOnFirstLaunch {
    if (![GVUserDefaults standardUserDefaults].showedHelpBarBounce) {
        [GVUserDefaults standardUserDefaults].showedHelpBarBounce = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self toggleButtonHandler:nil];
        });
    }
}

#pragma mark - Actions

- (IBAction)toggleButtonHandler:(id)sender
{
    if([self.semiModalController isOpen]) {
        CGFloat midHeight = self.view.frame.size.height * 0.1;
        CAKeyframeAnimation* animation = [[self class] dockBounceAnimationWithViewHeight:midHeight];
        [self.view.layer addAnimation:animation forKey:@"bouncing"];
    }
}

- (NSAttributedString *)helpText
{
    NSString *text = NSLocalizedString(@"TwittApp.net allows you to see who amongst your twitter friends are also on App.net\n\nSimply select your twitter account from the list and TwittApp.net will start looking for each of your twitter friend on app.net.\n\nFor each of your friend as status icon will indicate wether or not your friend is present on App.net.\n\nThe status bar at the bottom also gives you a summary to see at a glance how many friends you have in total and how many of them are on App.net.", nil);
    NSDictionary *attributes = @{
            NSFontAttributeName : [UIFont xig_regularFontOfSize:18],
            NSForegroundColorAttributeName : [UIColor whiteColor]
    };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

+ (CAKeyframeAnimation*)dockBounceAnimationWithViewHeight:(CGFloat)viewHeight
{
    NSUInteger const kNumFactors    = 22;
    CGFloat const kFactorsPerSec    = 30.0f;
    CGFloat const kFactorsMaxValue  = 128.0f;
    CGFloat factors[kNumFactors]    = {0,  60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32, 0, 0, 18, 28, 32, 28, 18, 0};

    NSMutableArray* transforms = [NSMutableArray array];

    for(NSUInteger i = 0; i < kNumFactors; i++)
    {
        CGFloat positionOffset  = factors[i] / kFactorsMaxValue * viewHeight;
        CATransform3D transform = CATransform3DMakeTranslation(0.0f, -positionOffset, 0.0f);

        [transforms addObject:[NSValue valueWithCATransform3D:transform]];
    }

    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.repeatCount           = 1;
    animation.duration              = kNumFactors * 1.0f/kFactorsPerSec;
    animation.fillMode              = kCAFillModeForwards;
    animation.values                = transforms;
    animation.removedOnCompletion   = YES; // final stage is equal to starting stage
    animation.autoreverses          = NO;

    return animation;
}

@end