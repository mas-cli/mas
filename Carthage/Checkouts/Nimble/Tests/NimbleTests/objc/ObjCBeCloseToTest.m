#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeCloseToTest : XCTestCase

@end

@implementation ObjCBeCloseToTest

- (void)testPositiveMatches {
    expect(@1.2).to(beCloseTo(@1.2001));
    expect(@1.2).to(beCloseTo(@2).within(10));
    expect(@2).toNot(beCloseTo(@1));
    expect(@1.00001).toNot(beCloseTo(@1).within(0.00000001));

    expect(1.2).to(beCloseTo(1.2001));
    expect(1.2).to(beCloseTo(2).within(10));
    expect(2).toNot(beCloseTo(1));
    expect(1.00001).toNot(beCloseTo(1).within(0.00000001));
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to be close to <0> (within 0.001), got <1>", ^{
        expect(@1).to(beCloseTo(@0));
    });
    expectFailureMessage(@"expected to not be close to <0> (within 0.001), got <0.0001>", ^{
        expect(@(0.0001)).toNot(beCloseTo(@0));
    });
    expectFailureMessage(@"expected to be close to <0> (within 0.001), got <1>", ^{
        expect(1).to(beCloseTo(0));
    });
    expectFailureMessage(@"expected to not be close to <0> (within 0.001), got <0.0001>", ^{
        expect(0.0001).toNot(beCloseTo(0));
    });
}

- (void)testNilMatches {
    expectNilFailureMessage(@"expected to be close to <0> (within 0.001), got <nil>", ^{
        expect(nil).to(beCloseTo(@0));
    });
    expectNilFailureMessage(@"expected to not be close to <0> (within 0.001), got <nil>", ^{
        expect(nil).toNot(beCloseTo(@0));
    });
}


@end
