//
//  XIGNSURLRequestBuilder.h
//  AppNetChecker
//
//  Created by Julien Grimault on 12/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
@interface XIGNSURLRequestBuilder : NSObject

@property(nonatomic, strong) ACAccount* account;

- (NSURLRequest*)requestForURL:(NSURL*)url parameters:(NSDictionary*)parameters;

@end
