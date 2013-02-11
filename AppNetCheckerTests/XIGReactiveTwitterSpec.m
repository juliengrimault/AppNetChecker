#import <Kiwi/Kiwi.h>
#import "XIGReactiveTwitter.h"
#import "KiwiHack.h"
#import "FakeAccountStore.h"

SPEC_BEGIN(XIGReactiveTwitterSpec)

__block XIGReactiveTwitter* reactiveTwitter;
beforeEach(^{
    reactiveTwitter = [[XIGReactiveTwitter alloc] init];
});


describe(@"getting the signal", ^{
    __block RACSignal* signal;
    beforeEach(^{
       signal = [reactiveTwitter twitterAccount];
    });
    
    it(@"should return non null", ^{
        [signal shouldNotBeNil];
    });
    
    it(@"should returns new signal everytime", ^{
        RACSignal* signal2 = [reactiveTwitter twitterAccount];
        [[signal2 shouldNot] equal:signal];
    });
});

describe(@"starting request", ^{
    __block FakeAccountStore* fakeStore;
    beforeEach(^{
        fakeStore = [[FakeAccountStore alloc] init];
        reactiveTwitter.accountStore = fakeStore;
    });
    
    describe(@"subscribing to signal", ^{
        it(@"should receive selector to get ACAccountType", ^{
            [[fakeStore should] receive:@selector(accountTypeWithAccountTypeIdentifier:) withArguments:ACAccountTypeIdentifierTwitter];
            [[fakeStore should] receive:@selector(requestAccessToAccountsWithType:options:completion:)];
            
            RACSignal* twitterAccounts = [reactiveTwitter twitterAccount];
            [twitterAccounts subscribeNext:^(id x) {}];
        });
    });

    describe(@"receiving values", ^{
        __block RACSignal* signal;
        __block NSArray* receivedAccounts = nil;
        __block NSError* receivedError = nil;
        beforeEach(^{
            signal = [reactiveTwitter twitterAccount];
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
                [[receivedAccounts shouldEventually] equal:fakeStore.accountsToReturn];
                [receivedError shouldBeNil];
            });
        });
        
        
        describe(@"access granted and error", ^{
            beforeEach(^{
                fakeStore.accessToReturn = YES;
                fakeStore.errorToReturn = [NSError errorWithDomain:@"Fake" code:123 userInfo:nil];
                fakeStore.accountsToReturn = nil;
            });
            
            it(@"should receive the accounts", ^{
                [fakeStore callRequestAccessHandler];
                [[receivedAccounts shouldEventually] beNil];
                [[receivedError shouldEventually] equal:fakeStore.errorToReturn];
            });
        });
        
        describe(@"access not granted and no error", ^{
            beforeEach(^{
                fakeStore.accessToReturn = NO;
                fakeStore.errorToReturn = nil;
                fakeStore.accountsToReturn = nil;
            });
            
            it(@"should create an error for access not granted receive the accounts", ^{
                [fakeStore callRequestAccessHandler];
                [[receivedError shouldEventually] beNonNil];
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
                [[receivedError shouldEventually] equal:fakeStore.errorToReturn];
            });
        });
    });
});

SPEC_END
