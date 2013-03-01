#import "KiwiHack.h"
#import "XIGAppNetClient.h"
#import <Nocilla/Nocilla.h>

SPEC_BEGIN(XIGAppNetClientSpec)

__block XIGAppNetClient *client;
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
    client = [[XIGAppNetClient alloc] init];
});

context(@"checking User existance", ^{
    __block RACSignal *signal;
    __block RACDisposable *disposable;
    
    beforeEach(^{
        signal = [client isUsernameOnAppNet:@"julien"];
    });
    
    afterEach(^{
        [disposable dispose];
    });
    
    it(@"should return a signal", ^{
        [signal shouldNotBeNil];
    });
    
    it(@"should enqueue a request when subcrisbing tothe signal", ^{
        [[client should] receive:@selector(enqueueHTTPRequestOperation:)];
        disposable = [signal subscribeNext:^(id x) {}];
    });
    
    context(@"queerying app.net", ^{
        __block NSNumber *receivedNext;
        __block NSError *receivedError;
        
        beforeEach(^{
            receivedNext = nil;
            receivedError = nil;
        });
        
        context(@"user exists", ^{
            beforeEach(^{
                NSString* path = [[NSBundle bundleForClass:[self class]] pathForResource:@"app.net.matt.txt" ofType:nil];
                stubRequest(@"GET", @"https://alpha.app.net/mattt").
                andReturnRawResponse([NSData dataWithContentsOfFile:path]);
                
                signal = [client isUsernameOnAppNet:@"mattt"];
                disposable = [signal subscribeNext:^(id x) {
                    receivedNext = x;
                } error:^(NSError *error) {
                    receivedError = error;
                }];
            });
            
            it(@"should send YES", ^{
                [[expectFutureValue(receivedNext) shouldEventually] equal:@YES];
            });
            
            it(@"should have no error", ^{
                [[expectFutureValue(receivedError) shouldEventually] beNil];
            });
        });
        
        context(@"user does not exist", ^{
            beforeEach(^{
                NSString* path = [[NSBundle bundleForClass:[self class]] pathForResource:@"app.net.doesnotexist.txt" ofType:nil];
                stubRequest(@"GET", @"https://alpha.app.net/doesnotexist").
                andReturnRawResponse([NSData dataWithContentsOfFile:path]);
                
                signal = [client isUsernameOnAppNet:@"doesnotexist"];
                disposable = [signal subscribeNext:^(id x) {
                    receivedNext = x;
                } error:^(NSError *error) {
                    receivedError = error;
                }];
            });
            
            it(@"should send YES", ^{
                [[expectFutureValue(receivedNext) shouldEventually] equal:@NO];
            });
            
            it(@"should have no error", ^{
                [[expectFutureValue(receivedError) shouldEventually] beNil];
            });
        });
        
        context(@"error", ^{
            beforeEach(^{
                stubRequest(@"GET", @"https://alpha.app.net/doesnotexist").
                andReturn(500);
                
                signal = [client isUsernameOnAppNet:@"whatever"];
                disposable = [signal subscribeNext:^(id x) {
                    receivedNext = x;
                } error:^(NSError *error) {
                    receivedError = error;
                }];
            });
            
            it(@"should not send next", ^{
                [[expectFutureValue(receivedNext) shouldEventually] beNil];
            });
            
            it(@"should have the error", ^{
                [[expectFutureValue(receivedError) shouldEventually] beNonNil];
            });
            
        });

    });
});
SPEC_END