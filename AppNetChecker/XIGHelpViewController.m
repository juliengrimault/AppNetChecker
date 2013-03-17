//
// Created by julien on 17/3/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "XIGHelpViewController.h"
#import "XIGSemiModalController.h"

@implementation XIGHelpViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureToggleButton];
    [self configureView];
}

- (void)configureToggleButton {
    self.toggleButton.titleLabel.textColor = [UIColor whiteColor];
    [self.toggleButton setBackgroundImage:[UIImage imageNamed:@"ToolBar.png"] forState:UIControlStateNormal];
    self.toggleButton.adjustsImageWhenHighlighted = NO;
    self.toggleButton.titleLabel.font = [UIFont xig_regularFontOfSize:[UIFont labelFontSize]];
    [self.toggleButton setTitle:NSLocalizedString(@"Find your Twitter friends on App.net", nil) forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(toggleButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureView
{
    self.view.backgroundColor = [UIColor xig_tableViewBackgroundColor];
    self.textView.attributedText = [self helpText];

}

- (IBAction)toggleButtonHandler:(id)sender
{
    [self.semiModalController toggleOpenAnimated:YES];
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

@end