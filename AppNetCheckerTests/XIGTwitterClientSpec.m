#import "KiwiHack.h"
#import "XIGTwitterClient.h"
#import "XIGTwitterClient+Private.h"
#import <Social/Social.h>
#import "ACAccount+XIGTest.h"
#import "XIGNSURLRequestBuilder.h"
#import "KWSpec+Fixture.h"

@interface XIGTwitterClient (XIGStub)
- (void)stubHTTPRequestOperationWithJSONToReturn:(id)json errorToReturn:(NSError*)error;
@end

SPEC_BEGIN(XIGTwitterClientSpec)

__block XIGTwitterClient* twitter;
__block XIGNSURLRequestBuilder* builder;
__block ACAccount* account;
beforeEach(^{
    twitter = [[XIGTwitterClient alloc] init];
    account = [ACAccount testAccount];
    builder = [[XIGNSURLRequestBuilder alloc] init];
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
    
    it(@"should lazyly load a request builder if none is provided", ^{
        [twitter.requestBuilder shouldNotBeNil];
    });
});

describe(@"Friends Ids Signal", ^{
    beforeEach(^{
        twitter.requestBuilder = builder;
        [builder stub:@selector(requestForURL:parameters:)
            andReturn:[[NSURLRequest alloc] initWithURL:[twitter friendsIdURL]]];
        [twitter stub:@selector(enqueueHTTPRequestOperation:)];
    });
    
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
            [[[builder should] receive] requestForURL:[twitter friendsIdURL] parameters:nil];
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
            friendsId = nil;
            receivedIds = nil;
            receivedError = nil;
        });
        
        describe(@"Receiving Error Response", ^{
            __block NSError* errorToReturn;
            
            beforeEach(^{
                errorToReturn = [NSError errorWithDomain:@"Test" code:123 userInfo:nil];
                [twitter stubHTTPRequestOperationWithJSONToReturn:nil errorToReturn:errorToReturn];
                
                friendsId = [twitter friendsId];
                [friendsId subscribeNext:^(id x) {
                    receivedIds = x;
                } error:^(NSError *error) {
                    receivedError = error;
                }];
            });
            
            it(@"should send an error to the subscriber", ^{
                [[expectFutureValue(receivedError) shouldEventually] equal:errorToReturn];
                [[expectFutureValue(receivedIds) shouldEventually] beNil];
            });
        });
        
        describe(@"Receiving Ids", ^{
            __block NSDictionary* jsonResponse;
            describe(@"receiving less than 1 page", ^{
                beforeEach(^{
                    jsonResponse = [KWSpec loadJSONFixture:@"friendsId.json"];
                    [twitter stubHTTPRequestOperationWithJSONToReturn:jsonResponse errorToReturn:nil];
                    
                    friendsId = [twitter friendsId];
                    [friendsId subscribeNext:^(id x) {
                        receivedIds = x;
                    } error:^(NSError *error) {
                        receivedError = error;
                    }];
                });
                
                it(@"should send the ids received", ^{
                    [[expectFutureValue(receivedError) shouldEventually] beNil];
                    [[expectFutureValue(receivedIds) shouldEventually] equal:jsonResponse[@"ids"]];
                });
            });
            
            describe(@"receiving more than 1 page", ^{
            });
        });

    });
});

SPEC_END

@implementation XIGTwitterClient (XIGStub)
- (void)stubHTTPRequestOperationWithJSONToReturn:(id)json errorToReturn:(NSError*)error
{
    [self stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
        NSURLRequest* urlRequest = params[0];
        void(^completionHandler)(AFHTTPRequestOperation *operation, id json) = params[1];
        void(^errorHandler)(AFHTTPRequestOperation *operation, NSError *error) = params[2];
        
        if (error) {
            errorHandler(nil, error);
        } else {
            completionHandler(nil, json);
        }
        return [[AFJSONRequestOperation alloc] initWithRequest:urlRequest];
    }];
}
@end