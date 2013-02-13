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
	NSURLRequest* request = [self.requestBuilder requestForURL:[self friendsIdURL] parameters:nil];
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:
                                         ^(AFHTTPRequestOperation *operation, id json)
                                         {
                                             NSArray* ids = json[@"ids"];
                                             [subject sendNext:ids];
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
