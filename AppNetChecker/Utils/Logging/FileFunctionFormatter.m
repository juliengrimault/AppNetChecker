//
// Created by julien on 30/3/13.
//
//


#import "FileFunctionFormatter.h"


@implementation FileFunctionFormatter

- (NSString*)formatLogMessage:(DDLogMessage *)logMessage
{
    return [NSString stringWithFormat:@"[%@-%d %@] %@",logMessage.fileName,logMessage->lineNumber,logMessage.methodName,logMessage->logMsg];
}
@end