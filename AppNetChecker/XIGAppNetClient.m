//
//  XIGAppNetClientSpec.m
//  AppNetChecker
//
//  Created by Julien Grimault on 1/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGAppNetClient.h"
#import "XIGAppNetUser.h"

@implementation XIGAppNetClient

+ (instancetype)sharedClient
{
    static dispatch_once_t once;
    static XIGAppNetClient *client;
    dispatch_once(&once, ^ { client = [[[self class] alloc] init]; });
    return client;
}

- (id)init
{
    return [self initWithBaseURL:[NSURL URLWithString:@"https://alpha.app.net"]];
}

- (RACSignal *)userWithScreenName:(NSString *)username
{
    @weakify(self);
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSURLRequest *request = [self requestWithMethod:@"GET"
                                                   path:username
                                             parameters:nil];
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                          success:
                                             ^(AFHTTPRequestOperation *requestOperation, id responseObject) {
                                                 XIGAppNetUser* user = [[XIGAppNetUser alloc] initWithScreenName:username
                                                                                                        htmlData:responseObject];
                                                 [subscriber sendNext:user];
                                                 [subscriber sendCompleted];
                                             }
                                                                          failure:
                                             ^(AFHTTPRequestOperation *requestOperation, NSError *error) {
                                                 if (requestOperation.response.statusCode == 404) {
                                                     //does not exist
                                                     [subscriber sendNext:nil];
                                                     [subscriber sendCompleted];
                                                 } else {
                                                     [subscriber sendError:error];
                                                 }
                                             }];
        operation.successCallbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        operation.failureCallbackQueue= dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [self enqueueHTTPRequestOperation:operation];
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
    return [signal replayLazily];
}
@end
