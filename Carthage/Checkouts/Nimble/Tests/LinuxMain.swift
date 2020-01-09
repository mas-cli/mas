import XCTest
@testable import NimbleTests

// This is the entry point for NimbleTests on Linux

XCTMain([
    testCase(AsyncTest.allTests),
    testCase(SynchronousTest.allTests),
    testCase(UserDescriptionTest.allTests),

    // Matchers
    testCase(AllPassTest.allTests),
    testCase(BeAKindOfSwiftTest.allTests),
    testCase(BeAnInstanceOfTest.allTests),
    testCase(BeCloseToTest.allTests),
    testCase(BeginWithTest.allTests),
    testCase(BeGreaterThanOrEqualToTest.allTests),
    testCase(BeGreaterThanTest.allTests),
    testCase(BeIdenticalToObjectTest.allTests),
    testCase(BeIdenticalToTest.allTests),
    testCase(BeLessThanOrEqualToTest.allTests),
    testCase(BeLessThanTest.allTests),
    testCase(BeTruthyTest.allTests),
    testCase(BeTrueTest.allTests),
    testCase(BeFalsyTest.allTests),
    testCase(BeFalseTest.allTests),
    testCase(BeNilTest.allTests),
    testCase(ContainTest.allTests),
    testCase(EndWithTest.allTests),
    testCase(EqualTest.allTests),
    testCase(HaveCountTest.allTests),
    testCase(MatchTest.allTests),
    // testCase(RaisesExceptionTest.allTests),
    testCase(ThrowErrorTest.allTests),
    testCase(SatisfyAnyOfTest.allTests),
    testCase(PostNotificationTest.allTests),
])
