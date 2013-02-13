//
//  KWSpec+Fixture.h
//  TradeHero
//
//  Created by Julien Grimault on 16/1/13.
//
//
#import "Kiwi.h"

@interface KWSpec (Fixture)

+ (id)loadJSONFixture:(NSString*)fileName;
@end
