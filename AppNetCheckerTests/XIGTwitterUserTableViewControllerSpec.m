#import "KiwiHack.h"
#import "XIGTwitterUsersTableViewController.h"
#import "UIStoryboard+AppNetChecker.h"
#import "XIGTwitterClient.h"
#import "XIGTwitterUser+XIGTest.h"
#import "XIGTwitterUserCell.h"
#import "XIGAppNetClient.h"
#import "XIGAppNetUser.h"
#import "XIGUserMatcher.h"

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

it(@"should load app.net client lazyly", ^{
    [[[[XIGAppNetClient class] should] receive] sharedClient];
    XIGAppNetClient *appNet = vc.appNetClient;
    [appNet shouldNotBeNil];
});

context(@"loading friends", ^{
    
    beforeEach(^{
        mockSignal = [[RACSignal return:friends1] concat:[RACSignal return:friends2]];
        vc.twitterClient = [XIGTwitterClient mock];
        [vc.twitterClient stub:@selector(friends) andReturn:mockSignal];
        
        vc.appNetClient = [XIGAppNetClient mock];
        __block NSInteger i = 0;
        [vc.appNetClient stub:@selector(userWithScreenName:) withBlock:^id(NSArray *params) {
            ++i;
            if (i % 5 == 0) {
                return [RACSignal return:nil];
            } if (i == 3) {
                return [RACSignal error:[NSError errorWithDomain:@"Test" code:123 userInfo:nil]];
            } else {
                NSString *username = params[0];
                XIGAppNetUser *user = [[XIGAppNetUser alloc] init];
                user.screenName = username;
                return [RACSignal return:user];
            }
        }];
    });
    
    it(@"should start retrieving the friends profiles", ^{
        [[[vc.twitterClient should] receive] friends];
        [vc view];
    });

    context(@"getting profiles back", ^{
        it(@"should append the users received to the users array", ^{
            [vc view];
            [[expectFutureValue(vc.users) shouldEventuallyBeforeTimingOutAfter(2)] haveCountOf:friends1.count + friends2.count];
        });
        
        it(@"should have a number of rows equal to the sum of the profiles received", ^{
            [vc view];
            KWFutureObject* futureNumberOfRows = [KWFutureObject futureObjectWithBlock:^id{
                return @([vc.tableView numberOfRowsInSection:0]);
            }];
            [[futureNumberOfRows shouldEventually] equal:@(friends1.count + friends2.count)];
        });
        
        context(@"loading app net users", ^{
            it(@"should receive 1 call per twitter friend", ^{
                [[expectFutureValue(vc.appNetClient) shouldEventually] receive:@selector(userWithScreenName:) withCount:friends1.count + friends2.count];
                [vc view];
            });
            
            it(@"should assign the received App.net user to the associated user of the twitter user property", ^{
                [vc view];
                KWFutureObject *future = [KWFutureObject futureObjectWithBlock:^id{
                    return [vc.users mtl_filterUsingBlock:^BOOL(XIGUserMatcher *matcher) {
                        return [matcher appNetUser] != nil;
                    }];
                }];
                [[future shouldEventuallyBeforeTimingOutAfter(2)] haveCountOf:7];
            });
        });
    });
});

context(@"Toolbar", ^{
    beforeEach(^{
        mockSignal = [[RACSignal return:friends1] delay:0.1];
        vc.twitterClient = [XIGTwitterClient mock];
        [vc.twitterClient stub:@selector(friends) andReturn:mockSignal];
    });
    
    it(@"should have loading indicator outlet connected", ^{
        [vc view];
        [vc.activityIndicator shouldNotBeNil];
    });
    
    it(@"should have an animating indicator", ^{
        [vc view];
        [[theValue([vc.activityIndicator isAnimating]) should] beTrue];
    });
    
    it(@"should stop animating when the signal completes", ^{
        [[expectFutureValue(@([vc.activityIndicator isAnimating])) shouldEventually] equal:@NO];
        [vc view];
    });
    
    it(@"should show the friends count", ^{
        [vc view];
        [vc.friendsCountLabel shouldNotBeNil];
    });
    
    it(@"should show the friends count", ^{
        [vc view];
        NSString* expectedText = [NSString stringWithFormat:@"%d friends", friends1.count];
        [[expectFutureValue(vc.friendsCountLabel.text) shouldEventually] equal:expectedText];
    });
    
});

SPEC_END