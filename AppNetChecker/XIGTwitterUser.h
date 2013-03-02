//
//  XIGTwitterUser.h
//  AppNetChecker
//
//  Created by Julien Grimault on 22/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
@class XIGAppNetUser;
@interface XIGTwitterUser : MTLModel

@property (nonatomic) NSInteger userId;
@property (nonatomic, copy) NSString* screenName;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, strong) NSURL* profileImageURL;

// the matching App.net user profile if any - nil by default
@property (nonatomic, strong) XIGAppNetUser* associatedAppNetUser;
@end
