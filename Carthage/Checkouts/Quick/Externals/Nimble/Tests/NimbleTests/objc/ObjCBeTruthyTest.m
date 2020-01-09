#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeTruthyTest : XCTestCase

@end

@implementation ObjCBeTruthyTest

- (void)testPositiveMatches {
    expect(@YES).to(beTruthy());
    expect(@NO).toNot(beTruthy());
    expect(nil).toNot(beTruthy());

    expect(true).to(beTruthy());
    expect(false).toNot(beTruthy());

    expect(YES).to(beTruthy());
    expect(NO).toNot(beTruthy());

    expect(10).to(beTruthy());
    expect(0).toNot(beTruthy());
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to be truthy, got <nil>", ^{
        expect(nil).to(beTruthy());
    });
    expectFailureMessage(@"expected to not be truthy, got <1>", ^{
        expect(@1).toNot(beTruthy());
    });
    expectFailureMessage(@"expected to be truthy, got <0>", ^{
        expect(@NO).to(beTruthy());
    });
    expectFailureMessage(@"expected to be truthy, got <0>", ^{
        expect(false).to(beTruthy());
    });
    expectFailureMessage(@"expected to not be truthy, got <1>", ^{
        expect(true).toNot(beTruthy());
    });
    expectFailureMessage(@"expected to be truthy, got <0>", ^{
        expect(NO).to(beTruthy());
    });
    expectFailureMessage(@"expected to not be truthy, got <1>", ^{
        expect(YES).toNot(beTruthy());
    });
    expectFailureMessage(@"expected to not be truthy, got <10>", ^{
        expect(10).toNot(beTruthy());
    });
    expectFailureMessage(@"expected to be truthy, got <0>", ^{
        expect(0).to(beTruthy());
    });
}

@end
