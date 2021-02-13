#import <XCTest/XCTest.h>
#import <Nimble/Nimble.h>
#import "NimbleSpecHelper.h"

@interface ObjCSyncTest : XCTestCase

@end

@implementation ObjCSyncTest

- (void)testFailureExpectation {
    expectFailureMessage(@"fail() always fails", ^{
        fail();
    });

    expectFailureMessage(@"This always fails", ^{
        failWithMessage(@"This always fails");
    });
}

#pragma mark - Assertion chaining

- (void)testChain {
    expect(@2).toNot(equal(@1)).to(equal(@2)).notTo(equal(@3));
}

- (void)testChainFail {
    expectFailureMessages((@[@"expected to not equal <2>, got <2>", @"expected to equal <3>, got <2>"]), ^{
        expect(@2).toNot(equal(@1)).toNot(equal(@2)).to(equal(@3));
    });
}

@end
