//
//  NSObject_KiwiHack.h
//  AppNetChecker
//
//  Created by Julien Grimault on 10/2/13.
//  Copyright (c) 2013 XiaoGou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Kiwi/Kiwi.h>

#ifdef SPEC_END
#undef SPEC_END
#define SPEC_END \
    } \
    - (void)testNothing{ NSLog(@""); }\
    \
    @end
#endif

