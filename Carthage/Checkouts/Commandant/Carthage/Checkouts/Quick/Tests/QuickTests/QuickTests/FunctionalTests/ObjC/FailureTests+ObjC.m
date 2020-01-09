@import XCTest;

@import Quick;
@import Nimble;

#import "QCKSpecRunner.h"

static BOOL isRunningFunctionalTests = NO;

#pragma mark - Spec

QuickSpecBegin(FunctionalTests_FailureSpec_ObjC)

describe(@"a group of failing examples", ^{
    it(@"passes", ^{
        expect(@YES).to(beTruthy());
    });

    it(@"fails (but only when running the functional tests)", ^{
        expect(@(isRunningFunctionalTests)).to(beFalsy());
    });

    it(@"fails again (but only when running the functional tests)", ^{
        expect(@(isRunningFunctionalTests)).to(beFalsy());
    });
});

QuickSpecEnd

#pragma mark - Tests

@interface FailureTests_ObjC : XCTestCase; @end

@implementation FailureTests_ObjC

- (void)setUp {
    [super setUp];
    isRunningFunctionalTests = YES;
}

- (void)tearDown {
    isRunningFunctionalTests = NO;
    [super tearDown];
}

- (void)testFailureSpecHasSucceededIsFalse {
    XCTestRun *result = qck_runSpec([FunctionalTests_FailureSpec_ObjC class]);
    XCTAssertFalse(result.hasSucceeded);
}

- (void)testFailureSpecExecutedAllExamples {
    XCTestRun *result = qck_runSpec([FunctionalTests_FailureSpec_ObjC class]);
    XCTAssertEqual(result.executionCount, 3);
}

- (void)testFailureSpecFailureCountIsEqualToTheNumberOfFailingExamples {
    XCTestRun *result = qck_runSpec([FunctionalTests_FailureSpec_ObjC class]);
    XCTAssertEqual(result.failureCount, 2);
}

@end
