#import "KiwiHack.h"
#import "XIGTwitterClient.h"
#import "XIGTwitterClient+Private.h"
#import <Social/Social.h>
#import "ACAccount+XIGTest.h"
#import "XIGNSURLRequestBuilder.h"
#import "KWSpec+Fixture.h"
#import "Nocilla.h"

SPEC_BEGIN(XIGTwitterClientSpec)

__block XIGTwitterClient* twitter;
__block XIGNSURLRequestBuilder* builder;
__block ACAccount* account;

beforeAll(^{
    [[LSNocilla sharedInstance] start];
});
afterAll(^{
    [[LSNocilla sharedInstance] stop];
});
afterEach(^{
    [[LSNocilla sharedInstance] clearStubs];
});

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
        it(@"should return a request signal", ^{
            [[[builder should] receive] requestForURL:[twitter friendsIdURL] parameters:any()];
            RACSignal* friendsId = [twitter friendsId];
            [friendsId shouldNotBeNil];
        });
        
        it(@"should enqueue the operation upon subscription to the signal", ^{
            RACSignal* friendsId = [twitter friendsId];
            [[expectFutureValue(twitter) shouldEventually] receive:@selector(HTTPRequestOperationWithRequest:success:failure:)];
            [[expectFutureValue(twitter) shouldEventually] receive:@selector(enqueueHTTPRequestOperation:)];
            
            [friendsId subscribeNext:^(id x) {}];
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
            beforeEach(^{
                
                stubRequest(@"GET", @"https://api.twitter.com/1.1/friends/ids.json?adc=phone&cursor=-1").
                withHeaders(@{@"Accept": @"application/json"}).
                andReturn(500);
                
                friendsId = [twitter friendsId];
                [friendsId subscribeNext:^(id x) {
                    receivedIds = x;
                } error:^(NSError *error) {
                    receivedError = error;
                }];
            });
            
            it(@"should send an error to the subscriber", ^{
                [[expectFutureValue(receivedError) shouldEventually] beNonNil];
                [[expectFutureValue(receivedIds) shouldEventually] beNil];
            });
        });
        
        describe(@"Receiving Ids", ^{
            __block NSDictionary* json;
            describe(@"receiving less than 1 page", ^{
                beforeEach(^{
                    json = [KWSpec jsonFixtureInFile:@"friendsId.json"];
                    stubRequest(@"GET", @"https://api.twitter.com/1.1/friends/ids.json?adc=phone&cursor=-1").
                    andReturn(200).
                    withHeaders(@{@"Content-Type": @"application/json"}).
                    withBody([KWSpec stringFixtureInFile:@"friendsId.json"]);
                    
                    friendsId = [twitter friendsId];
                    [friendsId subscribeNext:^(id x) {
                        receivedIds = x;
                    } error:^(NSError *error) {
                        receivedError = error;
                    }];
                });
                
                it(@"should send the ids received", ^{
                    [[expectFutureValue(receivedError) shouldEventually] beNil];
                    [[expectFutureValue(receivedIds) shouldEventually] equal:json[@"ids"]];
                });
            });
            
            describe(@"receiving more than 1 page", ^{
                __block NSDictionary* json1;
                __block NSDictionary* json2;
                beforeEach(^{
                    json1 = [KWSpec jsonFixtureInFile:@"friendsIdWithNextPage.json"];
                    json2 = [KWSpec jsonFixtureInFile:@"friendsId.json"];
                    
                    receivedIds = @[];
                    
                    stubRequest(@"GET", @"https://api.twitter.com/1.1/friends/ids.json?adc=phone&cursor=-1").
                    andReturn(200).
                    withHeaders(@{@"Content-Type": @"application/json"}).
                    withBody([KWSpec stringFixtureInFile:@"friendsIdWithNextPage.json"]);
                    
                    stubRequest(@"GET", @"https://api.twitter.com/1.1/friends/ids.json?adc=phone&cursor=10").
                    andReturn(200).
                    withHeaders(@{@"Content-Type": @"application/json"}).
                    withBody([KWSpec stringFixtureInFile:@"friendsId.json"]);
                    
                    friendsId = [twitter friendsId];
                    [friendsId subscribeNext:^(id x) {
                        receivedIds = [receivedIds arrayByAddingObjectsFromArray:x];
                    } error:^(NSError *error) {
                        receivedError = error;
                    }];
                });
                
                it(@"should send the ids received", ^{
                    [[expectFutureValue(receivedError) shouldEventually] beNil];
                    NSArray* expected = [json1[@"ids"] arrayByAddingObjectsFromArray:json2[@"ids"]];
                    [[expectFutureValue(receivedIds) shouldEventually] equal:expected];
                });
            });
        });
    });
});

SPEC_END