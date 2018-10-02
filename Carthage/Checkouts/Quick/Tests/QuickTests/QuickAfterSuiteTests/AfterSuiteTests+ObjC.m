@import XCTest;
@import Quick;
@import Nimble;

static BOOL afterSuiteFirstTestExecuted = NO;
static BOOL afterSuiteTestsWasExecuted = NO;

@interface AfterSuiteTests_ObjC : QuickSpec

@end

@implementation AfterSuiteTests_ObjC

- (void)spec {
    it(@"is executed before afterSuite", ^{
        expect(@(afterSuiteTestsWasExecuted)).to(beFalsy());
    });

    afterSuite(^{
        afterSuiteTestsWasExecuted = YES;
    });
}

+ (void)tearDown {
    if (afterSuiteFirstTestExecuted) {
        assert(afterSuiteTestsWasExecuted);
    } else {
        afterSuiteFirstTestExecuted = true;
    }
}

@end
