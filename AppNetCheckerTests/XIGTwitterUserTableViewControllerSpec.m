#import "KiwiHack.h"
#import "XIGTwitterUsersTableViewController.h"
#import "UIStoryboard+AppNetChecker.h"
#import "XIGTwitterClient.h"

SPEC_BEGIN(XIGTwitterUserTableViewControllerSpec)
__block XIGTwitterUsersTableViewController* vc;

beforeEach(^{
    vc = [[UIStoryboard mainStoryboard] instantiateViewControllerOfClass:[XIGTwitterUsersTableViewController class]];
});

it(@"should load properly", ^{
    [vc shouldNotBeNil];
});

it(@"should load twitter client lazyly", ^{
    [[[[XIGTwitterClient class] should] receive] sharedClient];
    XIGTwitterClient *client = vc.twitterClient;
    [client shouldNotBeNil];
});

context(@"view is loaded", ^{
    beforeEach(^{
        vc.twitterClient = [XIGTwitterClient mock];
    });
    
    it(@"should start retrieving the friends profiles", ^{
        [[[vc.twitterClient should] receive] friends];
        [vc view];
    });
});

SPEC_END