//
//  XIGTwitterEngine.m
//  AppNetChecker
//
//  Created by Julien Grimault on 12/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterClient.h"
#import "XIGTwitterClient+Private.h"
#import <Social/Social.h>
#import "XIGNSURLRequestBuilder.h"
#import <libextobjc/EXTScope.h>
#import "XIGTwitterUser.h"

NSString* const TwitterAPIBaseURL = @"https://api.twitter.com/1.1/";
@interface XIGTwitterClient () {
    XIGNSURLRequestBuilder* _requestBuilder;
}

@end
@implementation XIGTwitterClient

- (id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:TwitterAPIBaseURL]];
    if (self) {
        self.parameterEncoding = AFJSONParameterEncoding;
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    return self;
}


#pragma mark - Properties

- (XIGNSURLRequestBuilder*)requestBuilder
{
    if (!_requestBuilder) {
        _requestBuilder = [[XIGNSURLRequestBuilder alloc] init];
        _requestBuilder.account = self.account;
    }
    return _requestBuilder;
}

- (void)setRequestBuilder:(XIGNSURLRequestBuilder *)requestBuilder
{
    if (requestBuilder == _requestBuilder) return;
    _requestBuilder = requestBuilder;
    _requestBuilder.account = self.account;
}

- (void)setAccount:(ACAccount *)account
{
    if (_account == account) return;
    _account = account;
    _requestBuilder.account = account;
}

#pragma mark - Friends id

- (RACSignal*)friendsId
{
    NSParameterAssert(self.account != nil);
    return [self enqueueWithCursor:-1];
}

- (RACSignal*)enqueueWithCursor:(NSInteger)cursor
{
    @weakify(self);
    return [[self friendsIdAtCursor:cursor]
            // Map each `next` (there should only be one) to a new signal.
            flattenMap:^RACStream *(id json) {
                @strongify(self);
                NSArray* ids = json[@"ids"];
                
                // Prepare a signal representing the next page of results.
                NSNumber* nextCursor = json[@"next_cursor"];
                RACSignal* nextFriends = [RACSignal empty];
                if (nextCursor && ![nextCursor isEqualToNumber:@0]) {
                    nextFriends = [self enqueueWithCursor:[nextCursor integerValue]];
                }
                
                // Concatenate the results of this page with whatever comes from the
                // next page.
                return [[RACSignal return:ids] concat:nextFriends];
            }];
}
     

- (RACSignal*)friendsIdAtCursor:(NSInteger)cursor
{
    NSParameterAssert(self.account != nil);

    NSDictionary* parameters = @{ @"cursor" : [NSString stringWithFormat:@"%d",cursor] };
	NSURLRequest* request = [self.requestBuilder requestForURL:[self friendsIdURL] parameters:parameters];
    
    @weakify(self);
    // Using this method instead of a subject ensures that we don't start the
    // request until someone subscribes to the result.
    RACSignal* requestSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request
                                                                          success:
                                             ^(AFHTTPRequestOperation *operation, id json)
                                             {
                                                 [subscriber sendNext:json];
                                                 [subscriber sendCompleted];
                                             }
                                                                          failure:
                                             ^(AFHTTPRequestOperation *operation, NSError *error)
                                             {
                                                 [subscriber sendError:error];
                                             }];
        [self enqueueHTTPRequestOperation:operation];
        
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
    
    // Kicks off this request only when subscribed to, and makes sure that
    // a RACReplaySubject is used to buffer values.
    return [requestSignal replayLazily];
}

- (NSURL*)friendsIdURL
{
    return [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json"];
}


#pragma mark - Profiles
- (RACSignal*)profilesForIds:(NSArray*)ids
{
    NSParameterAssert(self.account);
    NSURL* url = [self profilesURL];
    NSURLRequest* request = [self.requestBuilder requestForURL:url parameters:@{ @"user_id" : [ids componentsJoinedByString:@","] }];
    @weakify(self);
    // Using this method instead of a subject ensures that we don't start the
    // request until someone subscribes to the result.
    RACSignal* requestSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request
                                                                          success:
                                             ^(AFHTTPRequestOperation *operation, id json)
                                             {
                                                 NSArray *users = [json mtl_mapUsingBlock:^id(NSDictionary* userJSON) {
                                                     return [[XIGTwitterUser alloc] initWithExternalRepresentation:userJSON];
                                                 }];
                                                 [subscriber sendNext:users];
                                                 [subscriber sendCompleted];
                                             }
                                                                          failure:
                                             ^(AFHTTPRequestOperation *operation, NSError *error)
                                             {
                                                 [subscriber sendError:error];
                                             }];
        [self enqueueHTTPRequestOperation:operation];
        
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
    
    // Kicks off this request only when subscribed to, and makes sure that
    // a RACReplaySubject is used to buffer values.
    return [requestSignal replayLazily];
}

- (NSURL*)profilesURL
{
    return [NSURL URLWithString:@"https://api.twitter.com/1.1/users/lookup.json"];
}
@end
