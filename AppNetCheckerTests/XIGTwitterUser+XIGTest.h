//
//  XIGTwitterUser+XIGTest.h
//  AppNetChecker
//
//  Created by Julien Grimault on 26/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import "XIGTwitterUser.h"

@interface XIGTwitterUser (XIGTest)

+ (instancetype)testUser:(NSInteger)n;
+(NSArray*)testUsers:(NSRange)range;
@end
