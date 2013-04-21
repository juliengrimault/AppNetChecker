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
                [twitterClient stub:@selector(friends) andReturn:[twitterFriends.rac_sequence signalWithScheduler:[RACScheduler immediateScheduler]]];
                signal = [client userMatchers];

                [appNetClient stub:@selector(userWithScreenName:)
                         andReturn:[RACSignal return:[[XIGAppNetUser alloc] initWithScreenName:@"Test" htmlData:nil]]];
            });

            afterEach(^{
                [disposable dispose];
            });

            it(@"should return a signal", ^{
                [signal shouldNotBeNil];
            });

            describe(@"building UserMatchers from twitter friends",^{
                __block NSMutableArray *receivedMatchers;
                __block NSError *receivedError;
                beforeEach(^{
                    receivedError = nil;
                    receivedMatchers = [NSMutableArray array];
                });

                it(@"should receive the same number of UserMatchers as the number of friends", ^{
                    [signal subscribeNext:^(id x) {
                        [receivedMatchers addObject:x];
                    } error:^(NSError *error) {
                        receivedError = error;
                    }];

                    [[receivedMatchers should] haveCountOf:twitterFriends.count];
                });

                it(@"each user matcher should have the twitter user", ^{
                    [signal subscribeNext:^(id x) {
                        [receivedMatchers addObject:x];
                    } error:^(NSError *error) {
                        receivedError = error;
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
                        [receivedMatchers addObject:x];
                    } error:^(NSError *error) {
                        receivedError = error;
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