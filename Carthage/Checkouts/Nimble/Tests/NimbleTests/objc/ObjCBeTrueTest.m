#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeTrueTest : XCTestCase

@end

@implementation ObjCBeTrueTest

- (void)testPositiveMatches {
    expect(@YES).to(beTrue());
    expect(@NO).toNot(beTrue());
    expect(nil).toNot(beTrue());

    expect(true).to(beTrue());
    expect(false).toNot(beTrue());

    expect(YES).to(beTrue());
    expect(NO).toNot(beTrue());
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to be true, got <0>", ^{
        expect(@NO).to(beTrue());
    });
    expectFailureMessage(@"expected to be true, got <nil>", ^{
        expect(nil).to(beTrue());
    });

    expectFailureMessage(@"expected to be true, got <0>", ^{
        expect(false).to(beTrue());
    });

    expectFailureMessage(@"expected to not be true, got <1>", ^{
        expect(true).toNot(beTrue());
    });

    expectFailureMessage(@"expected to be true, got <0>", ^{
        expect(NO).to(beTrue());
    });

    expectFailureMessage(@"expected to not be true, got <1>", ^{
        expect(YES).toNot(beTrue());
    });
}

@end
