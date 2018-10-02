#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCMatchTest : XCTestCase

@end

@implementation ObjCMatchTest

- (void)testPositiveMatches {
    expect(@"11:14").to(match(@"\\d{2}:\\d{2}"));
    expect(@"hello").toNot(match(@"\\d{2}:\\d{2}"));
}

- (void)testNegativeMatches {
    expectFailureMessage(@"expected to match <\\d{2}:\\d{2}>, got <hello>", ^{
        expect(@"hello").to(match(@"\\d{2}:\\d{2}"));
    });
    expectFailureMessage(@"expected to not match <\\d{2}:\\d{2}>, got <11:22>", ^{
        expect(@"11:22").toNot(match(@"\\d{2}:\\d{2}"));
    });
}

- (void)testNilMatches {
    expectNilFailureMessage(@"expected to match <\\d{2}:\\d{2}>, got <nil>", ^{
        expect(nil).to(match(@"\\d{2}:\\d{2}"));
    });
    expectNilFailureMessage(@"expected to not match <\\d{2}:\\d{2}>, got <nil>", ^{
        expect(nil).toNot(match(@"\\d{2}:\\d{2}"));
    });
}

@end
