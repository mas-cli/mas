#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCBeNilTest : XCTestCase

@end

@implementation ObjCBeNilTest

- (void)testPositiveMatches {
    expect(nil).to(beNil());
    expect(@NO).toNot(beNil());
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to be nil, got <1>", ^{
        expect(@1).to(beNil());
    });
    expectFailureMessage(@"expected to not be nil, got <nil>", ^{
        expect(nil).toNot(beNil());
    });
}

@end
