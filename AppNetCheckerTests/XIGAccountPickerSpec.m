#import "KiwiHack.h"
#import "ACAccount+KWMock.h"
#import "UIStoryboard+AppNetChecker.h"
#import "XIGAccountPickerViewController.h"
#import "UIViewController+SLServiceHack.h"
#import "XIGAccountErrorCell.h"

SPEC_BEGIN(XIGAccountPickerViewControllerSpec)

__block XIGAccountPickerViewController* vc;
__block XIGReactiveTwitter* fakeTwitter;

beforeEach(^{
    vc = [[UIStoryboard mainStoryboard] instantiateViewControllerOfClass:[XIGAccountPickerViewController class]];
    fakeTwitter = [XIGReactiveTwitter mock];
});

it(@"should load properly", ^{
    [vc shouldNotBeNil];
});

describe(@"view loaded", ^{
    beforeEach(^{
        [vc view];
    });
    
    it(@"should have tableview outlet connected", ^{
        [vc.tableView shouldNotBeNil];
        [[vc should] equal:vc.tableView.delegate];
        [[vc should] equal:vc.tableView.dataSource];
    });
    
    it(@"should have refresh outlet connected", ^{
        [vc.refreshControl shouldNotBeNil];
    });
    
    it(@"should have the refresh control connected to its action", ^{
        NSArray* actions = [vc.refreshControl actionsForTarget:vc forControlEvent: UIControlEventValueChanged];
        [[actions should] have:1];
    });
});


context(@"view is loaded", ^{
    beforeEach(^{
        vc.reactiveTwitter = fakeTwitter;
    });
    
    it(@"should start retrieving the accounts", ^{
        [[vc.reactiveTwitter should] receive:@selector(twitterAccount)];
        [vc view];
    });
});

context(@"Getting Twitter accounts", ^{
    beforeEach(^{
        vc.reactiveTwitter = fakeTwitter;
    });
    describe(@"successfully getting the accounts", ^{ 
        ACAccount* account = [ACAccount mockWithName:@"account"];
        ACAccount* account2 = [ACAccount mockWithName:@"account1"];
        NSArray* accounts = @[account, account2];
        RACSignal* signal = [RACSignal return:accounts];
        
        beforeEach(^{
            [[fakeTwitter should] receive:@selector(twitterAccount) andReturn:signal];
            [vc view];
        });
        
        it(@"should assign the retrieved accounts to the account property", ^{
            [[expectFutureValue(vc.accounts) shouldEventually] equal:accounts];
        });
        
        it(@"should show the accounts in the table view", ^{
            NSInteger i = 0;
            for(ACAccount* account in accounts) {
                KWFutureObject* future = [KWFutureObject futureObjectWithBlock:^id{
                    UITableViewCell* c = [vc.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                    return c.textLabel.text;
                }];
                [[future shouldEventually] equal:account.username];
                ++i;
            }
        });
    });
    
    describe(@"getting an error", ^{
        NSError* error = [NSError errorWithDomain:@"Test" code:123123 userInfo:nil];
        beforeEach(^{
            RACSignal* signal = [RACSignal error:error];
            [[fakeTwitter should] receive:@selector(twitterAccount) andReturn:signal];
            [vc view];
        });
        
        it(@"should assign the error to the error property", ^{
            [[expectFutureValue(vc.error) shouldEventually] beNonNil];
            [[expectFutureValue(vc.error) shouldEventually] equal:error];
        });
    });

});

context(@"error binding to UI elements", ^{
    beforeEach(^{
        [vc view];
    });
    
    describe(@"generic error", ^{
        __block UITableViewCell* errorCell;
        beforeEach(^{
            vc.error = [NSError errorWithDomain:@"Test" code:123 userInfo:nil];
            errorCell = [vc.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        });
        
        it(@"should show 1 row", ^{
            [[@([vc.tableView numberOfRowsInSection:0]) should] equal:@1];
        });
        
        it(@"should have its error label set", ^{
            [[(XIGAccountErrorCell*)errorCell errorLabel] shouldNotBeNil];
        });
        
        it(@"should have 1 cell of type ACAccountErrorCell", ^{
            [[errorCell should] beKindOfClass:[XIGAccountErrorCell class]];
        });
        
        it(@"the row should have the correct height", ^{
            CGFloat rowHeight = [vc tableView:vc.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            [[@(rowHeight) should] equal:@([XIGAccountErrorCell rowHeight])];
        });

    });

    describe(@"error is no account found", ^{
        it(@"should present a control to log in to the user", ^{
          //  [[vc should] receive:@selector(presentRegisterServiceViewControllerWithServiceType:) withArguments:SLServiceTypeTwitter];
            vc.error = [NSError errorWithDomain:ACErrorDomain code:ACErrorAccountNotFound userInfo:nil];
        });
    });
});

context(@"Pull to Refresh", ^{
    
    describe(@"refresh start and stop", ^{
        beforeEach(^{
            [vc view];
        });

        it(@"should start the refresh control", ^{
            [[@(vc.refreshControl.refreshing) should] equal:@YES];
        });
        
        it(@"should stop the refresh control eventually", ^{
            [[expectFutureValue(@(vc.refreshControl.refreshing)) shouldEventually] equal:@NO];
        });
    });
    
    describe(@"triggering refresh", ^{
        beforeEach(^{
            [vc view];
            vc.reactiveTwitter = fakeTwitter;
        });
        
        it(@"should reset the error and ask for twitter accounts", ^{
            [[[vc should] receive] setError:nil];
            [[[fakeTwitter should] receive] twitterAccount];
            [vc refreshControlValueChanged:nil];
        });
    });
});

SPEC_END