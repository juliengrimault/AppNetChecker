#import <Kiwi/Kiwi.h>
#import "JGReactiveTwitter.h"
#import "KiwiHack.h"
#import "FakeAccountStore.h"

SPEC_BEGIN(JGReactiveTwitterSpec)

__block JGReactiveTwitter* reactiveTwitter;
beforeEach(^{
    reactiveTwitter = [[JGReactiveTwitter alloc] init];
});


describe(@"getting the signal", ^{
    __block RACSignal* signal;
    beforeEach(^{
       signal = [reactiveTwitter twitterAccountSignal];
    });
    
    it(@"should return non null", ^{
        [signal shouldNotBeNil];
    });
    
    it(@"should always return the same signal", ^{
        RACSignal* signal2 = [reactiveTwitter twitterAccountSignal];
        [[signal2 should] equal:signal];
    });
});

describe(@"starting request", ^{
    __block FakeAccountStore* fakeStore;
    beforeEach(^{
        fakeStore = [[FakeAccountStore alloc] init];
        reactiveTwitter.accountStore = fakeStore;
    });
    
    it(@"should receive selector to get ACAccountType", ^{
        [[fakeStore should] receive:@selector(accountTypeWithAccountTypeIdentifier:) withArguments:ACAccountTypeIdentifierTwitter];
        [[fakeStore should] receive:@selector(requestAccessToAccountsWithType:options:completion:)];
        [reactiveTwitter twitterAccountSignal];
    });

    describe(@"receiving values", ^{
        __block RACSignal* signal;
        __block NSArray* receivedAccounts = nil;
        __block NSError* receivedError = nil;
        beforeEach(^{
            signal = [reactiveTwitter twitterAccountSignal];
            receivedError = nil;
            receivedAccounts = nil;
            
            [signal subscribeNext:^(id x) {
                receivedAccounts = x;
            }
                            error:
             ^(NSError *error) {
                 receivedError = error;
             }];
        });
        
        describe(@"access granted and no error", ^{
            beforeEach(^{
                fakeStore.accessToReturn = YES;
                fakeStore.accountsToReturn = @[@"account1", @"account2"];
            });
            
            it(@"should receive the accounts", ^{
                [fakeStore callRequestAccessHandler];
                [[receivedAccounts should] equal:fakeStore.accountsToReturn];
                [receivedError shouldBeNil];
            });
        });
        
        
        describe(@"access granted and error", ^{
            beforeEach(^{
                fakeStore.accessToReturn = YES;
                fakeStore.errorToReturn = [NSError errorWithDomain:@"Fake" code:123 userInfo:nil];
                fakeStore.accountsToReturn = @[@"account1", @"account2"];
            });
            
            it(@"should receive the accounts", ^{
                [fakeStore callRequestAccessHandler];
                [receivedAccounts shouldBeNil];
                [[receivedError should] equal:fakeStore.errorToReturn];
            });
        });
        
        describe(@"access not granted and no error", ^{
            beforeEach(^{
                fakeStore.accessToReturn = NO;
                fakeStore.accountsToReturn = @[@"account1", @"account2"];
            });
            
            it(@"should receive the accounts", ^{
                [fakeStore callRequestAccessHandler];
                [receivedAccounts shouldBeNil];
                [receivedError shouldBeNil];
            });
            
        });
        
        describe(@"access not granted and error", ^{
            beforeEach(^{
                fakeStore.accessToReturn = NO;
                fakeStore.errorToReturn = [NSError errorWithDomain:@"Fake" code:123 userInfo:nil];
                fakeStore.accountsToReturn = @[@"account1", @"account2"];
            });
            
            it(@"should receive the accounts", ^{
                [fakeStore callRequestAccessHandler];
                [receivedAccounts shouldBeNil];
                [[receivedError should] equal:fakeStore.errorToReturn];
            });
        });
    });
});

SPEC_END
