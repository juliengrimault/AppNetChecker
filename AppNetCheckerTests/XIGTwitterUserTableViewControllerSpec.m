#import "KiwiHack.h"
#import "XIGTwitterUsersTableViewController.h"
#import "UIStoryboard+AppNetChecker.h"
#import "XIGTwitterClient.h"
#import "XIGTwitterUser+XIGTest.h"
#import "XIGTwitterUserCell.h"
#import "XIGUserMatcher.h"
#import "XIGTwitAppClient.h"
#import "XIGUserMatcher+XIGTest.h"

SPEC_BEGIN(XIGTwitterUserTableViewControllerSpec)
__block XIGTwitterUsersTableViewController* vc;
__block RACSignal* mockSignal;
__block NSArray* friends1;
__block NSArray* friends2;
beforeEach(^{
    vc = [[UIStoryboard mainStoryboard] instantiateViewControllerOfClass:[XIGTwitterUsersTableViewController class]];
    
    friends1 = [XIGUserMatcher testUserMatchers:NSMakeRange(0, 5)];
    friends2 = [XIGUserMatcher testUserMatchers:NSMakeRange(5, 5)];
});

afterEach(^{
    mockSignal = nil;
    vc = nil;
});

it(@"should load properly", ^{
    [vc shouldNotBeNil];
});

context(@"loading friends", ^{
    beforeEach(^{
        mockSignal = [[RACSignal return:friends1] concat:[RACSignal return:friends2]];
        vc.twittAppClient= [XIGTwitAppClient mock];
        [vc.twittAppClient stub:@selector(userMatchers) andReturn:mockSignal];
    });
    
    it(@"should start retrieving the friends profiles", ^{
        [[[vc.twittAppClient should] receive] userMatchers];
        [vc view];
    });

    context(@"getting profiles back", ^{
        it(@"should append the users received to the users array", ^{
            [vc view];
            [[expectFutureValue(vc.userMatchers) shouldEventuallyBeforeTimingOutAfter(2)] haveCountOf:friends1.count + friends2.count];
        });
        
        it(@"should have a number of rows equal to the sum of the profiles received", ^{
            [vc view];
            KWFutureObject* futureNumberOfRows = [KWFutureObject futureObjectWithBlock:^id{
                return @([vc.tableView numberOfRowsInSection:0]);
            }];
            [[futureNumberOfRows shouldEventually] equal:@(friends1.count + friends2.count)];
        });
    });
});

context(@"Toolbar", ^{
    beforeEach(^{
        mockSignal = [RACSignal return:friends1];
        vc.twittAppClient = [XIGTwitAppClient mock];
        [vc.twittAppClient stub:@selector(userMatchers) andReturn:mockSignal];
    });
    
    it(@"should have loading indicator outlet connected", ^{
        [vc view];
        [vc.twitterLoadingIndicator shouldNotBeNil];
    });
    
    it(@"should have an animating indicator", ^{
        [vc view];
        [[theValue([vc.twitterLoadingIndicator isAnimating]) should] beTrue];
    });
    
    it(@"should stop animating when the signal completes", ^{
        [[expectFutureValue(@([vc.twitterLoadingIndicator isAnimating])) shouldEventually] equal:@NO];
        [vc view];
    });
    
    it(@"should show the friends count", ^{
        [vc view];
        [vc.friendsCountLabel shouldNotBeNil];
    });
    
    it(@"should update the friends count", ^{
        [vc view];
        NSString* expectedText = [NSString stringWithFormat:@"%d friends", friends1.count];
        [[expectFutureValue(vc.friendsCountLabel.text) shouldEventuallyBeforeTimingOutAfter(5)] equal:expectedText];
    });
    
    it(@"should have a label for found friends count", ^{
        [vc view];
        [vc.friendsFoundCountLabel shouldNotBeNil];
    });
    
});

SPEC_END