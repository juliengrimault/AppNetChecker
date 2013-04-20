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
    return [friends map:^id(XIGTwitterUser *twitterUser) {
        RACSignal *appNetUser = [[self.appNetClient userWithScreenName:twitterUser.screenName] catchTo:[RACSignal return:nil]];
        return [[XIGUserMatcher alloc] initWithTwitterUser:twitterUser appNetUserSignal:appNetUser];
    }];
}

@end