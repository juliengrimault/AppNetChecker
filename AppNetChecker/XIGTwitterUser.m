//
//  XIGTwitterUser.m
//  AppNetChecker
//
//  Created by Julien Grimault on 22/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterUser.h"

@implementation XIGTwitterUser

+ (NSDictionary *)externalRepresentationKeyPathsByPropertyKey
{
    return [[super externalRepresentationKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{  @"userId" : @"id",
                @"screenName" : @"screen_name",
                @"profileImageURL" : @"profile_image_url" }
            ];
}

+ (NSValueTransformer*)profileImageURLTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
