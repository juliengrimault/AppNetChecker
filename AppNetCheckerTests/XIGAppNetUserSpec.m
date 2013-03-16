#import "KiwiHack.h"
#import "XIGAppNetUser.h"
#import "KWSpec+Fixture.h"

SPEC_BEGIN(XIGAppNetUserSpec)

__block XIGAppNetUser *user;
__block NSData *data;

context(@"existing app.net user", ^{
    beforeEach(^{
        data = [KWSpec dataFixtureInFile:@"app.net.exists.html"];
        user = [[XIGAppNetUser alloc] initWithScreenName:nil htmlData:data];
    });

    it(@"should have the correct number of followers", ^{
        [[user.followerCount should] equal:@10];
    });

    it(@"should have the correct number of followings", ^{
        [[user.followingCount should] equal:@118];
    });
});

context(@"NON existent app.net user", ^{
    beforeEach(^{
        data = [KWSpec dataFixtureInFile:@"app.net.notexists.html"];
        user = [[XIGAppNetUser alloc] initWithScreenName:nil htmlData:data];
    });

    it(@"should not have a follower count", ^{
        [user.followerCount shouldBeNil];
    });

    it(@"should not have a follower count", ^{
        [user.followingCount shouldBeNil];
    });
});

SPEC_END