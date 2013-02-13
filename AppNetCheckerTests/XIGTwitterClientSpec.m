#import "KiwiHack.h"
#import "XIGTwitterClient.h"
#import "XIGTwitterClient+Private.h"
#import <Social/Social.h>
#import "ACAccount+XIGTest.h"
#import "XIGNSURLRequestBuilder.h"
#import "KWSpec+Fixture.h"

@interface XIGTwitterClient (XIGStub)
- (void)stubHTTPRequestOperationWithJSONToReturn:(id)json errorToReturn:(NSError*)error;
- (void)stubHTTPRequestOperationWithJSONRoutes:(NSDictionary*)routes;
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
        [builder stub:@selector(requestForURL:parameters:) withBlock:^id(NSArray *params) {
            NSURL* url = params[0];
            NSDictionary* parameters = params[1];
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                   requestMethod:SLRequestMethodGET
                                                             URL:url
                                                      parameters:parameters];
            return [request preparedURLRequest];
        }];
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
            [[[builder should] receive] requestForURL:[twitter friendsIdURL] parameters:any()];
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
                __block NSDictionary* jsonResponseNoNextPage;
                __block NSDictionary* jsonResponseWithNextPage;
                beforeEach(^{
                    receivedIds = @[];
                    jsonResponseWithNextPage = [KWSpec loadJSONFixture:@"friendsIdWithNextPage.json"];
                    jsonResponseNoNextPage = [KWSpec loadJSONFixture:@"friendsId.json"];
                    [twitter stubHTTPRequestOperationWithJSONRoutes:
                     @{ [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json"] : jsonResponseWithNextPage,
                        [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json?cursor=10"] : jsonResponseNoNextPage }];
                    
                    friendsId = [twitter friendsId];
                    [friendsId subscribeNext:^(id x) {
                        receivedIds = [receivedIds arrayByAddingObjectsFromArray:x];
                    } error:^(NSError *error) {
                        receivedError = error;
                    }];
                });
                
                it(@"should send the ids received", ^{
                    [[expectFutureValue(receivedError) shouldEventually] beNil];
                    NSArray* expected = [jsonResponseWithNextPage[@"ids"] arrayByAddingObjectsFromArray:jsonResponseNoNextPage[@"ids"]];
                    [[expectFutureValue(receivedIds) shouldEventually] equal:expected];
                });
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (error) {
                errorHandler(nil, error);
            } else {
                completionHandler(nil, json);
            }
        });
        return [[AFJSONRequestOperation alloc] initWithRequest:urlRequest];
    }];
}

- (void)stubHTTPRequestOperationWithJSONRoutes:(NSDictionary*)routes
{
    [self stub:@selector(HTTPRequestOperationWithRequest:success:failure:) withBlock:^id(NSArray *params) {
        NSURLRequest* urlRequest = params[0];
        void(^completionHandler)(AFHTTPRequestOperation *operation, id json) = params[1];
        void(^errorHandler)(AFHTTPRequestOperation *operation, NSError *error) = params[2];
        
        [routes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isEqual:urlRequest.URL]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if ([obj isKindOfClass:[NSError class]]) {
                        errorHandler(nil, obj);
                    } else {
                        completionHandler(nil, obj);
                    }
                });
            }
        }];
        return [[AFJSONRequestOperation alloc] initWithRequest:urlRequest];
    }];

}
@end