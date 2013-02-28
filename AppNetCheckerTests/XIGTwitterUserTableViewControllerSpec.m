#import "KiwiHack.h"
#import "XIGTwitterUsersTableViewController.h"
#import "UIStoryboard+AppNetChecker.h"
#import "XIGTwitterClient.h"
#import "XIGTwitterUser+XIGTest.h"
#import "XIGTwitterUserCell.h"

SPEC_BEGIN(XIGTwitterUserTableViewControllerSpec)
__block XIGTwitterUsersTableViewController* vc;
__block RACSignal* mockSignal;
__block NSArray* friends1;
__block NSArray* friends2;
beforeEach(^{
    vc = [[UIStoryboard mainStoryboard] instantiateViewControllerOfClass:[XIGTwitterUsersTableViewController class]];
    
    friends1 = [XIGTwitterUser testUsers:NSMakeRange(0, 5)];
    friends2 = [XIGTwitterUser testUsers:NSMakeRange(5, 5)];
});

afterEach(^{
    vc = nil;
    mockSignal = nil;
});

it(@"should load properly", ^{
    [vc shouldNotBeNil];
});

it(@"should load twitter client lazyly", ^{
    [[[[XIGTwitterClient class] should] receive] sharedClient];
    XIGTwitterClient *client = vc.twitterClient;
    [client shouldNotBeNil];
});

context(@"loading friends", ^{
    
    beforeEach(^{
        mockSignal = [[RACSignal return:friends1] concat:[[RACSignal return:friends2] delay:.3]];
        vc.twitterClient = [XIGTwitterClient mock];
        [vc.twitterClient stub:@selector(friends) andReturn:mockSignal];
    });
    
    it(@"should start retrieving the friends profiles", ^{
        [[[vc.twitterClient should] receive] friends];
        [vc view];
    });

    context(@"getting profiles back", ^{
        it(@"should append the users received to the users array", ^{
            [vc view];
            [[expectFutureValue(vc.friends) shouldEventuallyBeforeTimingOutAfter(2)] haveCountOf:friends1.count + friends2.count];
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

context(@"table view", ^{
    beforeEach(^{
        mockSignal = [RACSignal return:friends1];
        vc.twitterClient = [XIGTwitterClient mock];
        [vc.twitterClient stub:@selector(friends) andReturn:mockSignal];
    });
    
    it(@"should have cell of type XIGTwitterUserCell", ^{
        [vc view];
        [friends1 enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UITableViewCell* cell = [vc tableView:vc.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
            [[cell should] beKindOfClass:[XIGTwitterUserCell class]];
        }];
    });
});

context(@"Toolbar", ^{
    beforeEach(^{
        mockSignal = [[RACSignal return:friends1] delay:0.5];
        vc.twitterClient = [XIGTwitterClient mock];
        [vc.twitterClient stub:@selector(friends) andReturn:mockSignal];
        [vc view];
    });
    
    it(@"should have loading indicator outlet connected", ^{
        [vc.activityIndicator shouldNotBeNil];
    });
    
    it(@"should have an animating indicator", ^{
        [[theValue([vc.activityIndicator isAnimating]) should] beTrue];
    });
    
    it(@"should stop animating when the signal completes", ^{
        [[expectFutureValue(@([vc.activityIndicator isAnimating])) shouldEventually] equal:@NO];
    });
    
    it(@"should show the friends count", ^{
        [vc.friendsCountLabel shouldNotBeNil];
    });
    
    it(@"should show the friends count", ^{
        NSString* expectedText = [NSString stringWithFormat:@"%d friends", friends1.count];
        [[expectFutureValue(vc.friendsCountLabel.text) shouldEventually] equal:expectedText];
    });
    
});

SPEC_END