#import "KiwiHack.h"
#import "ACAccount+KWMock.h"
#import "UIStoryboard+AppNetChecker.h"
#import "JGAAccountPickerViewController.h"

SPEC_BEGIN(JGAAccountPickerViewControllerSpec)

__block JGAAccountPickerViewController* vc;
beforeEach(^{
    vc = [[UIStoryboard mainStoryboard] instantiateViewControllerOfClass:[JGAAccountPickerViewController class]];
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
});


describe(@"viewDidLoad", ^{
    __block JGReactiveTwitter* fakeTwitter;
    beforeEach(^{
        fakeTwitter = [JGReactiveTwitter mock];
        vc.reactiveTwitter = fakeTwitter;
    });
    
    it(@"should start retrieving the accounts", ^{
        [[vc.reactiveTwitter should] receive:@selector(twitterAccountSignal)];
        [vc view];
    });
    
    describe(@"successfully getting the accounts", ^{ 
        ACAccount* account = [ACAccount mockWithName:@"account"];
        ACAccount* account2 = [ACAccount mockWithName:@"account1"];
        NSArray* accounts = @[account, account2];
        RACSignal* signal = [RACSignal return:accounts];
        
        beforeEach(^{
            [[fakeTwitter should] receive:@selector(twitterAccountSignal) andReturn:signal];
            [vc view];
        });
        
        it(@"should assign the retrieved accounts to the account property", ^{
            [[vc.accounts shouldEventually] equal:accounts];
        });
        
        it(@"should show the accounts in the table view", ^{
            NSInteger i = 0;
            for(ACAccount* account in accounts) {
                UITableViewCell* c = [vc.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                [[c.textLabel.text shouldEventually] equal:account.username];
                ++i;
            }
        });
    });
    
    describe(@"getting an error", ^{
        NSError* error = [NSError errorWithDomain:@"Test" code:123123 userInfo:nil];
        beforeEach(^{
            RACSignal* signal = [RACSignal error:error];
            [[fakeTwitter should] receive:@selector(twitterAccountSignal) andReturn:signal];
            [vc view];
        });
        
        it(@"should show an error to the user", ^{
            [[vc.errorLabel shouldEventually] receive:@selector(setHidden:) withArguments:theValue(NO)];
        });
        
        it(@"should set the label with the error description", ^{
            [[vc.errorLabel.text shouldEventually] beNonNil];
        });
    });

});

SPEC_END