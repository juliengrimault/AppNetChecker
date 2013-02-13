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

#pragma mark -

- (RACSignal*)friendsId
{
    NSParameterAssert(self.account != nil);
    RACReplaySubject* subject = [RACReplaySubject subject];
    [self enqueueWithSubject:subject cursor:-1];
    return subject;
}

- (void)enqueueWithSubject:(RACSubject*)subject cursor:(NSInteger)cursor
{
    RACSignal* json = [self friendsIdAtCursor:cursor];
    @weakify(self);
    [json subscribeNext:^(id json) {
        @strongify(self);
        [subject sendNext:json[@"ids"]];
        NSNumber* nextCursor = json[@"next_cursor"];
        if (!nextCursor || [nextCursor isEqual:@0]) {
            [subject sendCompleted];
        } else {
            [self enqueueWithSubject:subject cursor:[nextCursor integerValue]];
        }
    } error:^(NSError *error) {
        [subject sendError:error];
    }];
}
     

- (RACSignal*)friendsIdAtCursor:(NSInteger)cursor
{
    NSParameterAssert(self.account != nil);
    RACReplaySubject* subject = [RACReplaySubject subject];
    NSDictionary* parameters = @{ @"cursor" : [NSString stringWithFormat:@"%d",cursor] };
	NSURLRequest* request = [self.requestBuilder requestForURL:[self friendsIdURL] parameters:parameters];
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:
                                         ^(AFHTTPRequestOperation *operation, id json)
                                         {
                                             [subject sendNext:json];
                                             [subject sendCompleted];
                                         }
                                                                      failure:
                                         ^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             [subject sendError:error];
                                         }];
    [self enqueueHTTPRequestOperation:operation];
    return subject;
}

- (NSURL*)friendsIdURL
{
    return [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json"];
}
@end
