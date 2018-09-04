#import <XCTest/XCTest.h>
#import "NimbleSpecHelper.h"

@interface ObjCUserDescriptionTest : XCTestCase

@end

@implementation ObjCUserDescriptionTest

- (void)testToWithDescription {
    expectFailureMessage(@"These are equal!\n"
                         "expected to equal <2>, got <1>", ^{
                             expect(@1).toWithDescription(equal(@2), @"These are equal!");
                         });
}

- (void)testToNotWithDescription {
    expectFailureMessage(@"These aren't equal!\n"
                         "expected to not equal <1>, got <1>", ^{
                             expect(@1).toNotWithDescription(equal(@1), @"These aren't equal!");
                         });
}

- (void)testNotToWithDescription {
    expectFailureMessage(@"These aren't equal!\n"
                         "expected to not equal <1>, got <1>", ^{
                             expect(@1).notToWithDescription(equal(@1), @"These aren't equal!");
                         });
}

- (void)testToEventuallyWithDescription {
    expectFailureMessage(@"These are equal!\n"
                         "expected to eventually equal <2>, got <1>", ^{
                             expect(@1).toEventuallyWithDescription(equal(@2), @"These are equal!");
                         });
}

- (void)testToEventuallyNotWithDescription {
    expectFailureMessage(@"These aren't equal!\n"
                         "expected to eventually not equal <1>, got <1>", ^{
                             expect(@1).toEventuallyNotWithDescription(equal(@1), @"These aren't equal!");
                         });
}

- (void)testToNotEventuallyWithDescription {
    expectFailureMessage(@"These aren't equal!\n"
                         "expected to eventually not equal <1>, got <1>", ^{
                             expect(@1).toNotEventuallyWithDescription(equal(@1), @"These aren't equal!");
                         });
}

@end
