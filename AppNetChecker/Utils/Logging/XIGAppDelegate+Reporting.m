//
// Created by julien on 30/3/13.
//
//


#import "XIGAppDelegate+Reporting.h"
#import "FileFunctionFormatter.h"
#import "CrashlyticsLogger.h"
#import <CocoaLumberjack/DDTTYLogger.h>
#import <Crashlytics/Crashlytics.h>

NSString *const CrashlyticsAPIKey = @"db76fbc48d24d6043bbf9cc8399d7e52f972c0d8";

@implementation XIGAppDelegate (Reporting)

- (void)setupCrashReporter
{
    [Crashlytics startWithAPIKey:CrashlyticsAPIKey];
}


- (void)setupLoggers
{
    FileFunctionFormatter *formatter = [[FileFunctionFormatter alloc] init];

    // does not log to console
    CrashlyticsLogger* crashLogger = [[CrashlyticsLogger alloc] init];
    [crashLogger setLogFormatter:formatter];
    [DDLog addLogger:crashLogger];

#ifdef DEBUG
    //setup console logger
    DDTTYLogger* consoleLogger = [DDTTYLogger sharedInstance];
    [consoleLogger setColorsEnabled:YES];
    [consoleLogger setLogFormatter:formatter];
    [DDLog addLogger:consoleLogger];
#endif

}
@end