//
//  XIGAppNetUser.h
//  AppNetChecker
//
//  Created by Julien Grimault on 2/3/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Mantle/Mantle.h>
@interface XIGAppNetUser : MTLModel

@property (nonatomic, copy) NSString* screenName;
@property  (nonatomic, strong) NSNumber *followerCount;
@property  (nonatomic, strong) NSNumber *followingCount;

- (id)initWithScreenName:(NSString *)screenName htmlData:(NSData *)htmlData;

@end
