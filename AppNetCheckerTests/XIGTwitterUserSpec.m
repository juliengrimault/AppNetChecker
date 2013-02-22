#import "KiwiHack.h"
#import "XIGTwitterUser.h"
#import "KWSpec+Fixture.h"

SPEC_BEGIN(XIGTwitterUserSpec)

describe(@"building a user from a dictionary", ^{
    __block XIGTwitterUser* user;
    __block NSDictionary* json;
    
    beforeEach(^{
        json = [KWSpec jsonFixtureInFile:@"twitterUser.json"];
        user = [[XIGTwitterUser alloc] initWithExternalRepresentation:json];
    });
    
    it(@"should have the id set", ^{
        [[@(user.userId) should] equal:json[@"id"]];
    });
    
    it(@"should have the username set", ^{
        [[user.screenName should] equal:json[@"screen_name"]];
    });
    
    it(@"should have the name set", ^{
        [[user.name should] equal:json[@"name"]];
    });
    
    it(@"should have the profile image URL set", ^{
        [[[user.profileImageURL absoluteString] should] equal:json[@"profile_image_url"]];
    });
});
SPEC_END