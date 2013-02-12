//
//  XIGTwitterEngine_Private.h
//  AppNetChecker
//
//  Created by Julien Grimault on 12/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterClient.h"
#import <Social/Social.h>
@interface XIGTwitterClient (Private)

- (NSURL*)friendsIdURL;
- (NSURLRequest*)requestForURL:(NSURL*)url parameters:(NSDictionary*)parameters;
@end
