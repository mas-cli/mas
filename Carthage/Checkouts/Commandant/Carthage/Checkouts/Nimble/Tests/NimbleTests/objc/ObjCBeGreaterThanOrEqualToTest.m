#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeGreaterThanOrEqualToTest : XCTestCase

@end

@implementation ObjCBeGreaterThanOrEqualToTest

- (void)testPositiveMatches {
    expect(@2).to(beGreaterThanOrEqualTo(@2));
    expect(@2).toNot(beGreaterThanOrEqualTo(@3));
    expect(2).to(beGreaterThanOrEqualTo(0));
    expect(2).to(beGreaterThanOrEqualTo(2));
    expect(2).toNot(beGreaterThanOrEqualTo(3));
    expect(2.5).to(beGreaterThanOrEqualTo(2));
    expect(2.5).to(beGreaterThanOrEqualTo(2.5));
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to be greater than or equal to <0>, got <-1>", ^{
        expect(@(-1)).to(beGreaterThanOrEqualTo(@0));
    });
    expectFailureMessage(@"expected to not be greater than or equal to <1>, got <2>", ^{
        expect(@2).toNot(beGreaterThanOrEqualTo(@(1)));
    });
    expectFailureMessage(@"expected to be greater than or equal to <0>, got <-1>", ^{
        expect(-1).to(beGreaterThanOrEqualTo(0));
    });
    expectFailureMessage(@"expected to not be greater than or equal to <1>, got <2>", ^{
        expect(2).toNot(beGreaterThanOrEqualTo(1));
    });
}

- (void)testNilMatches {
    expectNilFailureMessage(@"expected to be greater than or equal to <-1>, got <nil>", ^{
        expect(nil).to(beGreaterThanOrEqualTo(@(-1)));
    });
    expectNilFailureMessage(@"expected to not be greater than or equal to <1>, got <nil>", ^{
        expect(nil).toNot(beGreaterThanOrEqualTo(@(1)));
    });
}

@end
