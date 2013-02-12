#import "KiwiHack.h"
#import "XIGTwitterClient.h"
#import "XIGTwitterClient+Private.h"
#import <Social/Social.h>
#import "ACAccount+XIGTest.h"

SPEC_BEGIN(XIGTwitterClientSpec)

__block XIGTwitterClient* twitter;
__block ACAccount* account;
beforeEach(^{
    twitter = [[XIGTwitterClient alloc] init];
    account = [ACAccount testAccount];
    twitter.account = account;
});

describe(@"Initialization", ^{
    
    it(@"should be able to set a selected account", ^{
        [[twitter should] respondToSelector:@selector(setAccount:)];
        [[twitter should] respondToSelector:@selector(account)];
    });
    
    it(@"should have the base url set to twitter api url", ^{
        [[twitter.baseURL should] equal:[NSURL URLWithString:TwitterAPIBaseURL]];
    });
    
    it(@"should have the JSON type encoding", ^{
        [[@(twitter.parameterEncoding) should] equal:@(AFJSONParameterEncoding)];
    });
    
    it(@"should register AFHttpJSON as the default request class", ^{
        NSArray* registered = [twitter valueForKey:@"registeredHTTPOperationClassNames"];
        [[registered should] contain:NSStringFromClass([AFJSONRequestOperation class])];
    });
});

describe(@"Friends Ids Signal", ^{
    
    context(@"No Account set", ^{
        beforeEach(^{
            twitter.account = nil;
        });
        it(@"should raise an exception", ^{
            [[theBlock(^{
                [twitter friendsId];
            }) should] raise];
        });
    });
    
    describe(@"enqueuing operation", ^{
        
        it(@"should enqueue a request signal", ^{
            [[twitter should] receive:@selector(HTTPRequestOperationWithRequest:success:failure:)];
            [[twitter should] receive:@selector(enqueueHTTPRequestOperation:)];
            RACSignal* friendsId = [twitter friendsId];
            
            [friendsId shouldNotBeNil];
        });
    });
    
    describe(@"Receiving Callback", ^{
        __block RACSignal* friendsId;
        __block NSError* receivedError;
        __block NSArray* receivedIds;
        
        beforeEach(^{
        });
        
        describe(@"Receiving Error Response", ^{
            __block NSError* errorToReturn;
            
            beforeEach(^{
                errorToReturn = [NSError errorWithDomain:@"Test" code:123 userInfo:nil];
                [twitter stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
                    void(^errorHandler)(AFHTTPRequestOperation *operation, NSError *error) = params[2];
                    errorHandler(nil, errorToReturn);
                    return [[AFJSONRequestOperation alloc] initWithRequest:params[0]];
                }];
                
                friendsId = [twitter friendsId];
                [friendsId subscribeNext:^(id x) {
                    receivedIds = x;
                } error:^(NSError *error) {
                    receivedError = error;
                }];
            });
            
            it(@"should send an error to the subscriber", ^{
                [[receivedError shouldEventually] equal:errorToReturn];
                [[receivedIds shouldEventually] beNil];
            });
        });
        
        describe(@"Receiving Ids", ^{
            describe(@"receiving less than 1 page", ^{
            });
            
            describe(@"receiving more than 1 page", ^{
            });
        });

    });
});

SPEC_END