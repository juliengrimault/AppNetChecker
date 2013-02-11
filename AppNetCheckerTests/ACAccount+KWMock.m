//
//  KWMock+ACAccount.m
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "ACAccount+KWMock.h"

@implementation ACAccount (Mock)

+ (id)mockWithName:(NSString *)aName
{
    id mock = [super mockWithName:aName];
    [mock stub:@selector(username) andReturn:aName];
    return mock;
}
@end
