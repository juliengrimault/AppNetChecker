#import "KiwiHack.h"
#import "KWSpec+Fixture.h"
#import "XIGTwitterClient.h"
#import "XIGTwitterClient+Private.h"
#import "XIGNSURLRequestBuilder.h"
#import "ACAccount+XIGTest.h"
#import <Nocilla/Nocilla.h>
#import "XIGTwitterUser.h"

SPEC_BEGIN(XIGTwitterClientGetFriendsSpec)

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


// 7 friends to get: 1..7
// 2 pages: [1,2,3,4], [5,6,7]
// maxProfilePerRequest: 2
// friendsId
//   next: [1,2,3,4]
//         profilesForIds:
//              next: 1,2
//              next: 3,4
//   next: [5,6,7]
//          profilesForIds:
//              next: 5,6
//              next: 7

__block NSDictionary* ids1to4;
__block NSDictionary* ids5to7;
__block NSDictionary* users12;
__block NSDictionary* users34;
__block NSDictionary* users56;
__block NSDictionary* users7;

NSString *(^lookupPathForIds)(NSArray *) = ^NSString *(NSArray *ids) {
    NSString* encodedComma = @"%2C";
    return [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/lookup.json?adc=phone&user_id=%@",[ids componentsJoinedByString:encodedComma]];
};

describe(@"fetching all friend", ^{
    
    __block RACSignal* friends;
    __block RACDisposable* disposable;
    __block NSInteger numberOfNext;
    __block NSArray* receivedFriends;
    __block NSError* errorReceived;
    
    beforeEach(^{
        numberOfNext = 0;
        receivedFriends = @[];
        errorReceived = nil;
        
        twitter.maxProfileFetchedPerRequest = 2;
        
        ids1to4 = [KWSpec jsonFixtureInFile:@"friendsIdPage1.json"];
        ids5to7 = [KWSpec jsonFixtureInFile:@"friendsIdPage2.json"];
        users12 = [KWSpec jsonFixtureInFile:@"lookup12.json"];
        users34 = [KWSpec jsonFixtureInFile:@"lookup34.json"];
        users56 = [KWSpec jsonFixtureInFile:@"lookup56.json"];
        users7 = [KWSpec jsonFixtureInFile:@"lookup7.json"];
        
        stubRequest(@"GET", @"https://api.twitter.com/1.1/friends/ids.json?adc=phone&cursor=-1").
        andReturn(200).
        withHeaders(@{@"Content-Type": @"application/json"}).
        withBody([KWSpec stringFixtureInFile:@"friendsIdPage1.json"]);
        
        stubRequest(@"GET", @"https://api.twitter.com/1.1/friends/ids.json?adc=phone&cursor=5").
        andReturn(200).
        withHeaders(@{@"Content-Type": @"application/json"}).
        withBody([KWSpec stringFixtureInFile:@"friendsIdPage2.json"]);
        
        stubRequest(@"GET", lookupPathForIds(@[@1,@2])).
        andReturn(200).
        withHeaders(@{@"Content-Type": @"application/json"}).
        withBody([KWSpec stringFixtureInFile:@"lookup12.json"]);
        
        stubRequest(@"GET", lookupPathForIds(@[@3,@4])).
        andReturn(200).
        withHeaders(@{@"Content-Type": @"application/json"}).
        withBody([KWSpec stringFixtureInFile:@"lookup34.json"]);
        
        stubRequest(@"GET", lookupPathForIds(@[@5,@6])).
        andReturn(200).
        withHeaders(@{@"Content-Type": @"application/json"}).
        withBody([KWSpec stringFixtureInFile:@"lookup56.json"]);
        
        stubRequest(@"GET", lookupPathForIds(@[@7])).
        andReturn(200).
        withHeaders(@{@"Content-Type": @"application/json"}).
        withBody([KWSpec stringFixtureInFile:@"lookup7.json"]);
        
        friends = [twitter friends];
        disposable = [friends subscribeNext:^(id x) {
            receivedFriends = [receivedFriends arrayByAddingObjectsFromArray:x];
            ++numberOfNext;
        } error:^(NSError *error) {
            errorReceived = error;
        }];
    });
    
    afterEach(^{
        [disposable dispose];
    });
    
    it(@"should receive all the friends", ^{
        [friends shouldNotBeNil];
    });
    
    
    
    it(@"should receive 4 next:", ^{
        [[expectFutureValue(errorReceived) shouldEventuallyBeforeTimingOutAfter(2.0)] beNil];
        [[expectFutureValue(@(numberOfNext)) shouldEventuallyBeforeTimingOutAfter(2.0)] equal:@4];
    });
    
    it(@"should receive 7 objects back", ^{
        [[expectFutureValue(receivedFriends) shouldEventuallyBeforeTimingOutAfter(2.0)] haveCountOf:7];
    });
    
    it(@"should have 7 object of type XIGTwitterUser", ^{
        [[expectFutureValue((NSNumber*)[receivedFriends mtl_foldLeftWithValue:@YES usingBlock:^id(id left, id right) {
            BOOL b = [left boolValue];
            BOOL correctClass = [right isKindOfClass:[XIGTwitterUser class]];
            return @(b && correctClass);
        }]) should] equal:@YES];
    });
});

SPEC_END