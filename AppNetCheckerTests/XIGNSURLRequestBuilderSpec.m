#import "KiwiHack.h"
#import "XIGNSURLRequestBuilder.h"
#import <Social/Social.h>
#import "ACAccount+XIGTest.h"

SPEC_BEGIN(XIGNSURLRequestBuilderSpec)

__block XIGNSURLRequestBuilder* builder;
beforeEach(^{
    builder = [[XIGNSURLRequestBuilder alloc] init];
});

describe(@"URLRequest preparation", ^{
    __block NSURLRequest* request;
    __block NSURL* exampleURL;
    __block NSDictionary* parameters;
    __block SLRequest* fakeRequest;
    beforeEach(^{
        parameters = @{@"cursor" : @10 };
        exampleURL = [NSURL URLWithString:@"http://www.example.com"];
        fakeRequest = [SLRequest nullMock];
        [SLRequest stub:@selector(requestForServiceType:requestMethod:URL:parameters:) andReturn:fakeRequest];
    });
    
    it(@"should create the URL Request", ^{
        [[fakeRequest should] receive:@selector(preparedURLRequest)];
        request = [builder requestForURL:exampleURL parameters:parameters];
    });
    
    
    it(@"should not sign the request when there is not account", ^{
        [[fakeRequest shouldNot] receive:@selector(setAccount:)];
        [builder requestForURL:exampleURL parameters:parameters];
    });
    
    
    it(@"should sign the request with the account when there is one",^{
        builder.account = [ACAccount testAccount];
        [[fakeRequest should] receive:@selector(setAccount:)];
        [builder requestForURL:exampleURL parameters:parameters];
    });
});


SPEC_END