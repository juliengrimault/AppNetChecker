//
// Created by julien on 24/3/13.

//

#import <ReactiveCocoa/ReactiveCocoa/RACSignal.h>
#import "XIGTwitAppClient.h"
#import "XIGTwitterClient.h"
#import "XIGAppNetClient.h"
#import "XIGUserMatcher.h"

@interface XIGTwitAppClient()
@property (nonatomic, strong) XIGTwitterClient *twitterClient;
@property (nonatomic, strong) XIGAppNetClient  *appNetClient;
@end
@implementation XIGTwitAppClient {
}
- (id)initWithTwitterClient:(XIGTwitterClient *)twitter appNetClient:(XIGAppNetClient *)appNet {
    self = [super init];
    if (self) {
        _twitterClient = twitter;
        _appNetClient = appNet;
    }
    return self;
}

- (RACSignal *)userMatchers {
    RACSignal *friends = [self.twitterClient friends];
    return [friends flattenMap:^RACStream *(XIGTwitterUser *twitterUser) {
        //for each twitter user, lookup the app.net user and returns a signal combining the 2 into a XIGUserMatcher
        
        RACSignal *appNetUserSignal = [[self.appNetClient userWithScreenName:twitterUser.screenName] catch:^RACSignal *(NSError *error) {
            DDLogError(@"Error getting App.net user %@ - replacing by nil in sendNext", twitterUser.screenName);
            return [RACSignal empty];
        }];
        
        return [appNetUserSignal map:^id(XIGAppNetUser *appNetUser) {
            return [[XIGUserMatcher alloc] initWithTwitterUser:twitterUser appNetUser:appNetUser];
        }];
    }];
}

@end