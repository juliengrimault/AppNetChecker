//
//  KWSpec+Fixture.h
//  TradeHero
//
//  Created by Julien Grimault on 16/1/13.
//
//
#import "Kiwi.h"

@interface KWSpec (Fixture)

+ (id)jsonFixtureInFile:(NSString*)fileName;
+ (NSData*)dataFixtureInFile:(NSString*)fileName;
+ (NSString*)stringFixtureInFile:(NSString*)fileName;
@end
