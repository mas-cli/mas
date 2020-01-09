#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeGreaterThanTest : XCTestCase

@end

@implementation ObjCBeGreaterThanTest

- (void)testPositiveMatches {
    expect(@2).to(beGreaterThan(@1));
    expect(@2).toNot(beGreaterThan(@2));
    expect(@2).to(beGreaterThan(0));
    expect(@2).toNot(beGreaterThan(2));
    expect(2.5).to(beGreaterThan(1.5));
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to be greater than <0>, got <-1>", ^{
        expect(@(-1)).to(beGreaterThan(@(0)));
    });
    expectFailureMessage(@"expected to not be greater than <1>, got <2>", ^{
        expect(@2).toNot(beGreaterThan(@(1)));
    });
    expectFailureMessage(@"expected to be greater than <0>, got <-1>", ^{
        expect(-1).to(beGreaterThan(0));
    });
    expectFailureMessage(@"expected to not be greater than <1>, got <2>", ^{
        expect(2).toNot(beGreaterThan(1));
    });
}

- (void)testNilMatches {
    expectNilFailureMessage(@"expected to be greater than <-1>, got <nil>", ^{
        expect(nil).to(beGreaterThan(@(-1)));
    });
    expectNilFailureMessage(@"expected to not be greater than <1>, got <nil>", ^{
        expect(nil).toNot(beGreaterThan(@(1)));
    });
}

@end
