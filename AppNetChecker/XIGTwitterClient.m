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

NSString* const TwitterAPIBaseURL = @"https://api.twitter.com/1.1/";
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

#pragma mark -

- (RACSignal*)friendsId
{
    NSParameterAssert(self.account != nil);
    
    RACReplaySubject* subject = [RACReplaySubject subject];
	NSURLRequest* request = [self requestForURL:[self friendsIdURL] parameters:nil];
    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:
                                         ^(AFHTTPRequestOperation *operation, id json)
                                         {
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
