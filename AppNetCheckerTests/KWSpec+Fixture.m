//
//  KWSpec+Fixture.m
//  TradeHero
//
//  Created by Julien Grimault on 16/1/13.
//
//

#import "KWSpec+Fixture.h"

@implementation KWSpec (Fixture)

+ (NSData*)dataFixtureInFile:(NSString*)fileName
{
    NSString* file =[[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:nil];
    NSData* data = [NSData dataWithContentsOfFile:file];
    if (!data) {
        NSLog(@"could not load fixture: %@", file);
    }
    return data;
}

+ (NSString*)stringFixtureInFile:(NSString*)fileName
{
    NSData* data = [self dataFixtureInFile:fileName];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (id)jsonFixtureInFile:(NSString*)fileName
{
    NSData* data = [self dataFixtureInFile:fileName];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    return json;
}
@end
