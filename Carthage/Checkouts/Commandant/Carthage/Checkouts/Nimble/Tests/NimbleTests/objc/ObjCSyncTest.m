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

@end
