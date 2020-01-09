@import XCTest;
@import Quick;
@import Nimble;

#import "QCKSpecRunner.h"

QuickSpecBegin(FunctionalTests_SharedExamples_Spec_ObjC)

itBehavesLike(@"a group of three shared examples", ^NSDictionary*{ return @{}; });

QuickSpecEnd

QuickSpecBegin(FunctionalTests_SharedExamples_ContextSpec_ObjC)

itBehavesLike(@"shared examples that take a context", ^NSDictionary *{
    return @{ @"callsite": @"SharedExamplesSpec" };
});

QuickSpecEnd

QuickSpecBegin(FunctionalTests_SharedExamples_SameContextSpec_ObjC)

__block NSInteger counter = 0;

afterEach(^{
    counter++;
});

sharedExamples(@"gets called with a different context from within the same spec file", ^(QCKDSLSharedExampleContext exampleContext) {
    
    it(@"tracks correctly", ^{
        NSString *payload = exampleContext()[@"payload"];
        BOOL expected = [payload isEqualToString:[NSString stringWithFormat:@"%ld", (long)counter]];
        expect(@(expected)).to(beTrue());
    });
    
});

itBehavesLike(@"gets called with a different context from within the same spec file", ^{
    return @{ @"payload" : @"0" };
});

itBehavesLike(@"gets called with a different context from within the same spec file", ^{
    return @{ @"payload" : @"1" };
});

QuickSpecEnd


@interface SharedExamplesTests_ObjC : XCTestCase; @end

@implementation SharedExamplesTests_ObjC

- (void)testAGroupOfThreeSharedExamplesExecutesThreeExamples {
    XCTestRun *result = qck_runSpec([FunctionalTests_SharedExamples_Spec_ObjC class]);
    XCTAssert(result.hasSucceeded);
    XCTAssertEqual(result.executionCount, 3);
}

- (void)testSharedExamplesWithContextPassContextToExamples {
    XCTestRun *result = qck_runSpec([FunctionalTests_SharedExamples_ContextSpec_ObjC class]);
    XCTAssert(result.hasSucceeded);
}

@end
