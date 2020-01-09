#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeFalsyTest : XCTestCase

@end

@implementation ObjCBeFalsyTest

- (void)testPositiveMatches {
    expect(@NO).to(beFalsy());
    expect(@YES).toNot(beFalsy());
    expect(nil).to(beFalsy());

    expect(true).toNot(beFalsy());
    expect(false).to(beFalsy());

    expect(YES).toNot(beFalsy());
    expect(NO).to(beFalsy());

    expect(10).toNot(beFalsy());
    expect(0).to(beFalsy());
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to not be falsy, got <nil>", ^{
        expect(nil).toNot(beFalsy());
    });
    expectFailureMessage(@"expected to be falsy, got <1>", ^{
        expect(@1).to(beFalsy());
    });
    expectFailureMessage(@"expected to not be falsy, got <0>", ^{
        expect(@NO).toNot(beFalsy());
    });

    expectFailureMessage(@"expected to be falsy, got <1>", ^{
        expect(true).to(beFalsy());
    });
    expectFailureMessage(@"expected to not be falsy, got <0>", ^{
        expect(false).toNot(beFalsy());
    });

    expectFailureMessage(@"expected to be falsy, got <1>", ^{
        expect(YES).to(beFalsy());
    });
    expectFailureMessage(@"expected to not be falsy, got <0>", ^{
        expect(NO).toNot(beFalsy());
    });

    expectFailureMessage(@"expected to be falsy, got <10>", ^{
        expect(10).to(beFalsy());
    });
    expectFailureMessage(@"expected to not be falsy, got <0>", ^{
        expect(0).toNot(beFalsy());
    });
}

@end
