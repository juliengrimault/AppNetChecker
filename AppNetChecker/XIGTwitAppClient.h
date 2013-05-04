//
// Created by julien on 24/3/13.
//
//
#import <Foundation/Foundation.h>

@class XIGTwitterClient;
@class XIGAppNetClient;
@class RACSignal;

@interface XIGTwitAppClient : NSObject

@property (nonatomic, strong, readonly) XIGTwitterClient *twitterClient;
@property (nonatomic, strong, readonly) XIGAppNetClient  *appNetClient;

- (id)initWithTwitterClient:(XIGTwitterClient *)twitter appNetClient:(XIGAppNetClient *)appNet;

- (RACSignal *)userMatchers;

@end