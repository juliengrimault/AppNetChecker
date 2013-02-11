#import "KiwiHack.h"
#import "UIStoryboard+AppNetChecker.h"

SPEC_BEGIN(UIStoryboardSpec)

describe(@"load the main storyboard", ^{
   it(@"should load properly", ^{
       UIStoryboard* storyboard = [UIStoryboard mainStoryboard];
       [storyboard shouldNotBeNil];
   });
});

SPEC_END