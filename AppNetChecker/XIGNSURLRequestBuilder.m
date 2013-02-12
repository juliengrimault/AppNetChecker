//
//  XIGNSURLRequestBuilder.m
//  AppNetChecker
//
//  Created by Julien Grimault on 12/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGNSURLRequestBuilder.h"
#import <Social/Social.h>
@implementation XIGNSURLRequestBuilder


- (NSURLRequest*)requestForURL:(NSURL*)url parameters:(NSDictionary*)parameters
{
    SLRequest* request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:parameters];
    if (self.account) {
        [request setAccount:self.account];
    }
    return [request preparedURLRequest];
}

@end
