//
//  XIGAppNetClientSpec.h
//  AppNetChecker
//
//  Created by Julien Grimault on 1/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface XIGAppNetClient : AFHTTPClient

+(instancetype)sharedClient;

- (RACSignal *)userWithScreenName:(NSString *)username;
@end
