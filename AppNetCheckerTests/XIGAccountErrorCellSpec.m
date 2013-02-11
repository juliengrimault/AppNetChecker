#import "KiwiHack.h"
#import "XIGAccountErrorCell.h"

SPEC_BEGIN(XIGAccountErrorCellSpec)

__block XIGAccountErrorCell* cell;
beforeEach(^{
    cell = [[XIGAccountErrorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Id"];
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectZero];
    [cell.contentView addSubview:l];
    cell.errorLabel = l;
});
describe(@"binding an error", ^{
    beforeEach(^{
        NSError* error = [NSError errorWithDomain:@"Test" code:123 userInfo:nil];
        [cell bindError:error];
    });
    
    it(@"should have a text set", ^{
        [cell.errorLabel.text shouldNotBeNil];
    });
});

SPEC_END