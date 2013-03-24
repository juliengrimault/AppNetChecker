//
// Created by julien on 24/3/13.
//
//
#import <Foundation/Foundation.h>

@class XIGTwitterClient;
@class XIGAppNetClient;
@class RACSignal;

@interface XIGTwitAppClient : NSObject

- (id)initWithTwitterClient:(XIGTwitterClient *)twitter appNetClient:(XIGAppNetClient *)appNet;

- (RACSignal *)userMatchers;
@end