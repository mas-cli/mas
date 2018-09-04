#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCSatisfyAllOfTest : XCTestCase

@end

@implementation ObjCSatisfyAllOfTest

- (void)testPositiveMatches {
    expect(@2).to(satisfyAllOf(equal(@2), beLessThan(@3)));
    expect(@2).toNot(satisfyAllOf(equal(@3), equal(@16)));
    expect(@[@1, @2, @3]).to(satisfyAllOf(equal(@[@1, @2, @3]), allPass(beLessThan(@4))));
    expect(@NO).toNot(satisfyAllOf(beTrue(), beFalse()));
    expect(@YES).toNot(satisfyAllOf(beTrue(), beFalse()));
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to match all of: {equal <3>}, and {equal <4>}, and {equal <5>}, got 2", ^{
        expect(@2).to(satisfyAllOf(equal(@3), equal(@4), equal(@5)));
    });
    
    expectFailureMessage(@"expected to match all of: {all be less than <4>, but failed first at element"
                         " <5> in <[5, 6, 7]>}, and {equal <(1, 2, 3, 4)>}, got (5,6,7)", ^{
                             expect(@[@5, @6, @7]).to(satisfyAllOf(allPass(beLessThan(@4)), equal(@[@1, @2, @3, @4])));
                         });
    
    expectFailureMessage(@"satisfyAllOf must be called with at least one matcher", ^{
        expect(@"turtles").to(satisfyAllOf());
    });
}
@end
