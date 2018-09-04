@import XCTest;
@import Quick;
@import Nimble;

#import "QCKSpecRunner.h"

static BOOL beforeSuiteWasExecuted = NO;

QuickSpecBegin(FunctionalTests_BeforeSuite_BeforeSuiteSpec_ObjC)

beforeSuite(^{
    beforeSuiteWasExecuted = YES;
});

QuickSpecEnd

QuickSpecBegin(FunctionalTests_BeforeSuite_Spec_ObjC)

it(@"is executed after beforeSuite", ^{
    expect(@(beforeSuiteWasExecuted)).to(beTruthy());
});

QuickSpecEnd

@interface BeforeSuiteTests_ObjC : XCTestCase; @end

@implementation BeforeSuiteTests_ObjC

- (void)testBeforeSuiteIsExecutedBeforeAnyExamples {
    // Execute the spec with an assertion before the one with a beforeSuite
    NSArray *specs = @[
        [FunctionalTests_BeforeSuite_Spec_ObjC class],
        [FunctionalTests_BeforeSuite_BeforeSuiteSpec_ObjC class]
    ];
    XCTestRun *result = qck_runSpecs(specs);
    XCTAssert(result.hasSucceeded);
}

@end
