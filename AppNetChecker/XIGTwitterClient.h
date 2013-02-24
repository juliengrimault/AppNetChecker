//
//  XIGTwitterEngine.h
//  AppNetChecker
//
//  Created by Julien Grimault on 12/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFNetworking.h>

OBJC_EXTERN NSString *const TwitterAPIBaseURL;

@class XIGNSURLRequestBuilder;
@interface XIGTwitterClient : AFHTTPClient

@property (nonatomic, strong) ACAccount *account;
@property (nonatomic, strong) XIGNSURLRequestBuilder *requestBuilder;
@property (nonatomic) NSInteger maxProfileFetchedPerRequest;


- (RACSignal *)friends;
- (RACSignal *)friendsId;
- (RACSignal *)profilesForIds:(NSArray *)ids;

+ (instancetype)sharedClient;
@end
