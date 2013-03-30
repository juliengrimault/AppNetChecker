//
//  CrashlyticsLogger.m
//
//  Created by Julien Grimault on 4/1/13.
//
//

#import "CrashlyticsLogger.h"
#import <Crashlytics/Crashlytics.h>


@implementation CrashlyticsLogger

- (void)logMessage:(DDLogMessage *)logMessage
{
    NSString    *logMsg     = nil;
    logMsg = logMessage->logMsg;
    
    if (logMsg != nil)
    {
        if (formatter != nil)
        {
            logMsg = [formatter formatLogMessage:logMessage];
        }
        
        CLSLog(@"%@",logMsg);
    }
    return;
}

@end
