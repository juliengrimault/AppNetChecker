//
//  XIGAppNetClientSpec.m
//  AppNetChecker
//
//  Created by Julien Grimault on 1/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGAppNetClient.h"

@implementation XIGAppNetClient

- (id)init
{
    return [self initWithBaseURL:[NSURL URLWithString:@"https://alpha.app.net"]];
}

- (RACSignal *)isUsernameOnAppNet:(NSString *)username
{
    @weakify(self);
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSURLRequest *request = [self requestWithMethod:@"GET"
                                                   path:username
                                             parameters:nil];
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                          success:
                                             ^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 [subscriber sendNext:@YES];
                                                 [subscriber sendCompleted];
                                             }
                                                                          failure:
                                             ^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 if (operation.response.statusCode == 404) {
                                                     //does not exist
                                                     [subscriber sendNext:@NO];
                                                     [subscriber sendCompleted];
                                                 } else {
                                                     [subscriber sendError:error];
                                                 }
                                             }];
        [self enqueueHTTPRequestOperation:operation];
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
    return [signal replayLazily];
}
@end
