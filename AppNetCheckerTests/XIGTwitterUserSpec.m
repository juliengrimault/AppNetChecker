#import "KiwiHack.h"
#import "XIGTwitterUser.h"
#import "KWSpec+Fixture.h"
#import "XIGAppNetUser.h"

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
    
    it(@"should have the profile image URL set to the original size image URL", ^{
        NSString *normalURL = json[@"profile_image_url"];
        NSString *expectedURL = [normalURL stringByReplacingOccurrencesOfString:@"_normal." withString:@"."];
        [[[user.profileImageURL absoluteString] should] equal:expectedURL];
    });
    
    it(@"should not have a associated AppNet user", ^{
        [user.associatedAppNetUser shouldBeNil];
    });
});
SPEC_END