@import XCTest;
@import Quick;

#import "QCKSpecRunner.h"

static BOOL isRunningFunctionalTests = NO;

QuickSpecBegin(FunctionalTests_FailureUsingXCTAssertSpec_ObjC)

it(@"fails using an XCTAssert (but only when running the functional tests)", ^{
    XCTAssertFalse(isRunningFunctionalTests);
});

it(@"fails again using an XCTAssert (but only when running the functional tests)", ^{
    XCTAssertFalse(isRunningFunctionalTests);
});

it(@"succeeds using an XCTAssert", ^{
    XCTAssertTrue(YES);
});

QuickSpecEnd

#pragma mark - Tests

@interface FailureUsingXCTAssertTests_ObjC : XCTestCase; @end

@implementation FailureUsingXCTAssertTests_ObjC

- (void)setUp {
    [super setUp];
    isRunningFunctionalTests = YES;
}

- (void)tearDown {
    isRunningFunctionalTests = NO;
    [super tearDown];
}

- (void)testFailureUsingXCTAssertSpecHasSucceededIsFalse {
    XCTestRun *result = qck_runSpec([FunctionalTests_FailureUsingXCTAssertSpec_ObjC class]);
    XCTAssertFalse(result.hasSucceeded);
}

- (void)testFailureUsingXCTAssertSpecExecutedAllExamples {
    XCTestRun *result = qck_runSpec([FunctionalTests_FailureUsingXCTAssertSpec_ObjC class]);
    XCTAssertEqual(result.executionCount, 3);
}

- (void)testFailureUsingXCTAssertSpecFailureCountIsEqualToTheNumberOfFailingExamples {
    XCTestRun *result = qck_runSpec([FunctionalTests_FailureUsingXCTAssertSpec_ObjC class]);
    XCTAssertEqual(result.totalFailureCount, 2);
}

@end
