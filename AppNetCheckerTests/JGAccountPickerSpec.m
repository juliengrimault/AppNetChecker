#import "KiwiHack.h"
#import "ACAccount+KWMock.h"
#import "UIStoryboard+AppNetChecker.h"
#import "JGAAccountPickerViewController.h"
#import "UIViewController+SLServiceHack.h"

SPEC_BEGIN(JGAAccountPickerViewControllerSpec)

__block JGAAccountPickerViewController* vc;
__block JGReactiveTwitter* fakeTwitter;

beforeEach(^{
    vc = [[UIStoryboard mainStoryboard] instantiateViewControllerOfClass:[JGAAccountPickerViewController class]];
    fakeTwitter = [JGReactiveTwitter mock];
});

it(@"should load properly", ^{
    [vc shouldNotBeNil];
});

describe(@"view loaded", ^{
    beforeEach(^{
        [vc view];
    });
    
    it(@"should have error label outlet connected", ^{
        [vc.errorLabel shouldNotBeNil];
        [[theValue(vc.errorLabel.hidden) should] beTrue];
    });
    
    it(@"should have tableview outlet connected", ^{
        [vc.tableView shouldNotBeNil];
        [[vc should] equal:vc.tableView.delegate];
        [[vc should] equal:vc.tableView.dataSource];
    });
    
    it(@"should have retry button outlet connected and hidden", ^{
        [vc.retryButton shouldNotBeNil];
        [[theValue(vc.retryButton.hidden) should] beTrue];
    });
    
    it(@"should have the retry button connected to its action", ^{
        NSArray* actions = [vc.retryButton actionsForTarget:vc forControlEvent:UIControlEventTouchUpInside];
        [[actions should] have:1];
    });
});


describe(@"viewDidLoad", ^{
    beforeEach(^{
        vc.reactiveTwitter = fakeTwitter;
    });
    
    it(@"should start retrieving the accounts", ^{
        [[vc.reactiveTwitter should] receive:@selector(twitterAccount)];
        [vc view];
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

describe(@"error binding to UI elements", ^{
    beforeEach(^{
        [vc view];
    });
    
    describe(@"generic error", ^{
        beforeEach(^{
            vc.error = [NSError errorWithDomain:@"Test" code:123 userInfo:nil];
        });
        
        it(@"should show the error label", ^{
            [[theValue(vc.errorLabel.hidden) should] beFalse];
        });
        
        it(@"should update the error label message", ^{
            [vc.errorLabel.text shouldNotBeNil];
        });
        
        it(@"should show the retry button", ^{
            [[theValue(vc.retryButton.hidden) should] beFalse];
        });

    });
    
    describe(@"error is no account found", ^{
        it(@"should present a control to log in to the user", ^{
            //[[vc should] receive:@selector(presentRegisterServiceViewControllerWithServiceType:) withArguments:SLServiceTypeTwitter];
            vc.error = [NSError errorWithDomain:ACErrorDomain code:ACErrorAccountNotFound userInfo:nil];
        });
    });
    
    describe(@"Retry Button", ^{
        beforeEach(^{
            vc.reactiveTwitter = fakeTwitter;
        });
        
        it(@"should reset the error and ask for twitter accounts", ^{
            [[[vc should] receive] setError:nil];
            [[[fakeTwitter should] receive] twitterAccount];
            [vc retryButtonHandler:nil];
        });
    });
});

SPEC_END