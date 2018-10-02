#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeFalseTest : XCTestCase

@end

@implementation ObjCBeFalseTest

- (void)testPositiveMatches {
    expect(@NO).to(beFalse());
    expect(@YES).toNot(beFalse());

    expect(false).to(beFalse());
    expect(true).toNot(beFalse());

    expect(NO).to(beFalse());
    expect(YES).toNot(beFalse());

    expect(10).toNot(beFalse());
}

- (void)testNegativeMatches {
    expectNilFailureMessage(@"expected to be false, got <nil>", ^{
        expect(nil).to(beFalse());
    });
    expectNilFailureMessage(@"expected to not be false, got <nil>", ^{
        expect(nil).toNot(beFalse());
    });

    expectFailureMessage(@"expected to be false, got <1>", ^{
        expect(true).to(beFalse());
    });
    expectFailureMessage(@"expected to not be false, got <0>", ^{
        expect(false).toNot(beFalse());
    });

    expectFailureMessage(@"expected to be false, got <1>", ^{
        expect(YES).to(beFalse());
    });
    expectFailureMessage(@"expected to not be false, got <0>", ^{
        expect(NO).toNot(beFalse());
    });
}

@end
