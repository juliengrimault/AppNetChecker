//
//  KWSpec+Fixture.m
//  TradeHero
//
//  Created by Julien Grimault on 16/1/13.
//
//

#import "KWSpec+Fixture.h"
#import "DDLog.h"

@implementation KWSpec (Fixture)

+ (id)loadJSONFixture:(NSString*)fileName
{
    NSString* file =[[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:nil];
    NSData* data = [NSData dataWithContentsOfFile:file];
    if (!data) {
        NSLog(@"could not load fixture: %@", file);
    }
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    return json;
}
@end
