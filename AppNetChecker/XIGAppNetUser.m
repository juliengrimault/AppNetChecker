//
//  XIGAppNetUser.m
//  AppNetChecker
//
//  Created by Julien Grimault on 2/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGAppNetUser.h"
#import "TFHpple.h"

static NSString *const followingXPathQuery = @"//strong[@data-follow-from-count]";
static NSString *const followerXPathQuery = @"//strong[@data-follow-to-count]";

@interface XIGAppNetUser()
@property (nonatomic, strong) NSData *rawData;
@end

@implementation XIGAppNetUser

- (id)initWithScreenName:(NSString *)screenName htmlData:(NSData *)htmlData {
    self = [super init];
    if (self) {
        _screenName = [screenName copy];
        _rawData = [htmlData copy];
        [self parseRawData];
    }
    return self;
}

- (void)parseRawData
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:self.rawData];
    self.followingCount = [self extractNumberFromDocument:doc xpathQuery:followingXPathQuery];
    self.followerCount= [self extractNumberFromDocument:doc xpathQuery:followerXPathQuery];
}

- (NSNumber *)extractNumberFromDocument:(TFHpple *)doc xpathQuery:(NSString *)query
{
    TFHppleElement *followingCountElement = [doc peekAtSearchWithXPathQuery:query];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *n = [f numberFromString:followingCountElement.firstChild.content];
    return n;
}


@end
