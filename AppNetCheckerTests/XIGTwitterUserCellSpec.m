#import "KiwiHack.h"
#import "XIGTwitterUserCell.h"
#import "XIGUserMatcher.h"
#import "XIGTwitterUser.h"
#import "UIView+JGLoadFromNib.h"
#import <AFNetworking/AFNetworking.h>
#import "XIGAppNetClient.h"

SPEC_BEGIN(XIGTwitterUserCellSpec)

__block XIGTwitterUser *user;
__block XIGUserMatcher* matcher;
__block XIGTwitterUserCell *cell;

beforeEach(^{
    user = [[XIGTwitterUser alloc] init];
    user.userId = 123;
    user.screenName = @"screenName";
    user.name = @"name surname";
    user.profileImageURL = [NSURL URLWithString:@"https://si0.twimg.com/profile_images/2554344631/59zr2d5mvh9ergt7c8fi.jpeg"];
    
    matcher = [[XIGUserMatcher alloc] initWithTwitterUser:user appNetClient:nil];
    cell = [XIGTwitterUserCell loadInstanceFromNib];
});

describe(@"loading from xib", ^{
    it(@"should load the xib with the same name as the class", ^{
        [cell shouldNotBeNil];
    });
    
    it(@"should have username label outlet connected", ^{
        [cell.usernameLabel shouldNotBeNil];
    });
    
    it(@"should have user profile image outlet connected", ^{
        [cell.profileImageView shouldNotBeNil];
    });
    
    it(@"should have user full name outlet connected", ^{
        [cell.fullnameLabel shouldNotBeNil];
    });
    
    it(@"should have activity outlet connected", ^{
        [cell.activityIndicator shouldNotBeNil];
    });
});

describe(@"binding user", ^{
    beforeEach(^{
        [cell bindUserMatcher:matcher];
    });
    
    it(@"should have the username set", ^{
        [[cell.usernameLabel.text should] equal:[NSString stringWithFormat:@"@%@",[user.screenName uppercaseString]]];
    });
    
    it(@"should have the name set", ^{
        [[cell.fullnameLabel.text should] equal:user.name];
    });
    
    it(@"should be animating", ^{
        [[@([cell.activityIndicator isAnimating]) should] equal:@YES];
    });
});

describe(@"image loading", ^{
    it(@"should set the image url", ^{
        [[[cell.profileImageView should] receive] setImageWithURL:user.profileImageURL];
        [cell bindUserMatcher:matcher];
    });
    
    it(@"should cancel the operation when reusing the cell", ^{
        [[[cell.profileImageView should] receive] cancelImageRequestOperation];
        [cell prepareForReuse];
    });
    
});

describe(@"binding activity indicator", ^{
    beforeAll(^{
        XIGAppNetClient *client = [XIGAppNetClient mock];
        XIGAppNetUser* appNetUser = [[XIGAppNetUser alloc] init];
        user.screenName = user.screenName;
        [client stub:@selector(userWithScreenName:) andReturn:[RACSignal return:appNetUser]];
        matcher = [[XIGUserMatcher alloc] initWithTwitterUser:user appNetClient:client];
        [cell bindUserMatcher:matcher];
    });
    
    afterEach(^{
        [cell prepareForReuse];
    });
    
    it(@"should stop animating eventually", ^{
        [[expectFutureValue(@([cell.activityIndicator isAnimating])) shouldEventually] equal:@NO];
    });
});
SPEC_END