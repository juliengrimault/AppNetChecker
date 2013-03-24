#import "KiwiHack.h"
#import "XIGTwitAppClient.h"
#import "XIGTwitterClient.h"
#import "XIGAppNetClient.h"
#import "XIGTwitterUser+XIGTest.h"
#import "XIGUserMatcher.h"

SPEC_BEGIN(XIGTwitAppClientSpec)
        __block XIGTwitAppClient *client;
        __block XIGTwitterClient *twitterClient;
        __block XIGAppNetClient *appNetClient;
        beforeEach(^{
            twitterClient = [XIGTwitterClient mock];
            appNetClient = [XIGAppNetClient mock];
            client = [[XIGTwitAppClient alloc]  initWithTwitterClient:twitterClient appNetClient:appNetClient];
        });

        describe(@"Fetching Matchers between Twitter and App.net", ^{
            __block RACSignal *signal;
            __block RACDisposable *disposable;
            __block NSArray *twitterFriends;
            beforeEach(^{
                twitterFriends = [XIGTwitterUser testUsers:NSMakeRange(0, 10)];
                [twitterClient stub:@selector(friends) andReturn:[RACSignal return:twitterFriends]];
                signal = [client userMatchers];

                [appNetClient stub:@selector(userWithScreenName:) andReturn:[[XIGAppNetUser alloc] initWithScreenName:@"Test" htmlData:nil]];
            });

            afterEach(^{
                [disposable dispose];
            });

            it(@"should return a signal", ^{
                [signal shouldNotBeNil];
            });

            describe(@"building UserMatchers from twitter friends",^{
                __block NSArray *receivedMatchers;
                __block NSArray *receivedError;
                beforeEach(^{
                    receivedError = nil;
                    receivedMatchers = nil;
                });

                it(@"should receive the same number of UserMatchers as the number of friends", ^{
                    [signal subscribeNext:^(id x) {
                        receivedMatchers = x;
                    } error:^(NSError *error) {
                        receivedError = nil;
                    }];

                    [[receivedMatchers should] haveCountOf:twitterFriends.count];
                });

                it(@"each user matcher should have the twitter user", ^{
                    [signal subscribeNext:^(id x) {
                        receivedMatchers = x;
                    } error:^(NSError *error) {
                        receivedError = nil;
                    }];

                    NSUInteger i = 0;
                    for (XIGTwitterUser *u in twitterFriends) {
                        XIGUserMatcher *matcher = receivedMatchers[i];
                        [[matcher.twitterUser should] equal:u];
                        i++;
                    }
                });

                it(@"each user matcher should have a app.net user signal", ^{
                    [signal subscribeNext:^(id x) {
                        receivedMatchers = x;
                    } error:^(NSError *error) {
                        receivedError = nil;
                    }];

                    NSUInteger i = 0;
                    for (XIGTwitterUser *u in twitterFriends) {
                        XIGUserMatcher *matcher = receivedMatchers[i];
                        [matcher.appNetUser shouldNotBeNil];
                    }
                });
            });
        });


SPEC_END