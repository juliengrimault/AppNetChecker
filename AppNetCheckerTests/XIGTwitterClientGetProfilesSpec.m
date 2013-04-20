#import "KiwiHack.h"
#import "XIGTwitterClient.h"
#import <Accounts/Accounts.h>
#import "XIGNSURLRequestBuilder.h"
#import <Nocilla/Nocilla.h>
#import "ACAccount+XIGTest.h"
#import <Social/Social.h>
#import "XIGTwitterClient+Private.h"
#import "KWSpec+Fixture.h"
#import "XIGTwitterUser.h"

SPEC_BEGIN(XIGTwitterClientGetProfilesSpec)


__block XIGTwitterClient* twitter;
__block XIGNSURLRequestBuilder* builder;
__block ACAccount* account;
__block NSArray* ids;

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
    ids = @[@123, @456, @789];
    twitter.account = account;
});


describe(@"Friends Profile Signal", ^{
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
                [twitter profilesForIds:ids];
            }) should] raise];
        });
    });
    
    describe(@"enqueuing operation", ^{
        it(@"should return a request signal", ^{
            [[[builder should] receive] requestForURL:[twitter profilesURL] parameters:any()];
            RACSignal* profiles = [twitter profilesForIds:ids];
            [profiles subscribeNext:^(id x) {}];
            [profiles shouldNotBeNil];
        });
        
        it(@"should set the user_id looked up according to the input parameter", ^{
            NSDictionary* expected = @{ @"user_id" : [ids componentsJoinedByString:@","] };
            [[[builder should] receive] requestForURL:[twitter profilesURL] parameters:expected];
            RACSignal* profiles = [twitter profilesForIds:ids];
            [profiles subscribeNext:^(id x) {}];
        });
        
        it(@"should enqueue the operation upon subscription to the signal", ^{
            RACSignal* profiles = [twitter profilesForIds:ids];
            [[expectFutureValue(twitter) shouldEventually] receive:@selector(HTTPRequestOperationWithRequest:success:failure:)];
            [[expectFutureValue(twitter) shouldEventually] receive:@selector(enqueueHTTPRequestOperation:)];
            
            [profiles subscribeNext:^(id x) {}];
        });
    });
    
    describe(@"Receiving Callback", ^{
        __block RACSignal* profiles;
        __block RACDisposable* disposable;
        __block NSError* receivedError;
        __block NSMutableArray* receivedProfiles;
        __block NSString* path;
        
        beforeEach(^{
            profiles = nil;
            receivedProfiles = [NSMutableArray array];
            receivedError = nil;
            NSString* encodedComma = @"%2C";
            path = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/lookup.json?adc=phone&user_id=%@",[ids componentsJoinedByString:encodedComma]];
        });
        
        afterEach(^{
            [disposable dispose];
        });
        
        describe(@"Receiving Error Response", ^{
            beforeEach(^{
                stubRequest(@"GET", path).
                withHeaders(@{@"Accept": @"application/json"}).
                andReturn(500);
                
                profiles = [twitter profilesForIds:ids];
                disposable = [profiles subscribeNext:^(id x) {
                    [receivedProfiles addObject:x];
                } error:^(NSError *error) {
                    receivedError = error;
                }];
            });
            
            it(@"should send an error to the subscriber", ^{
                [[expectFutureValue(receivedError) shouldEventually] beNonNil];
                [[expectFutureValue(receivedProfiles) shouldEventually] haveCountOf:0];
            });
        });
        
        describe(@"Receiving Profiles", ^{
            __block NSDictionary* json;
            beforeEach(^{
                json = [KWSpec jsonFixtureInFile:@"lookup.json"];
                
                stubRequest(@"GET", path).
                andReturn(200).
                withHeaders(@{@"Content-Type": @"application/json"}).
                withBody([KWSpec stringFixtureInFile:@"lookup.json"]);
            });
            
            describe(@"requesting less than 1 page of profiles", ^{
                beforeEach(^{
                    profiles = [twitter profilesForIds:ids];
                    disposable = [profiles subscribeNext:^(id x) {
                        [receivedProfiles addObject:x];
                    } error:^(NSError *error) {
                        receivedError = error;
                    }];
                });
                
                it(@"should send the ids received", ^{
                    [[expectFutureValue(receivedError) shouldEventually] beNil];
                    [[[expectFutureValue(receivedProfiles) shouldEventually] have:json.count] elements];
                    [receivedProfiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [[obj should] beKindOfClass:[XIGTwitterUser class]];
                    }];
                });
            });
            
            describe(@"requesting more than 1 page of profiles ", ^{
                beforeEach(^{
                    twitter.maxProfileFetchedPerRequest = ids.count;
                    
                    profiles = [twitter profilesForIds:[ids arrayByAddingObjectsFromArray:ids]];
                    disposable = [profiles subscribeNext:^(id x) {
                        [receivedProfiles addObject:x];
                    } error:^(NSError *error) {
                        receivedError = error;
                    }];
                });
                
                it(@"should receive the profiles split in 2 sendNext:", ^{
                    [[expectFutureValue(receivedError) shouldEventually] beNil];
                    [[[expectFutureValue(receivedProfiles) shouldEventually] have:json.count * 2] elements];
                });
            });
        });
    });

});
SPEC_END