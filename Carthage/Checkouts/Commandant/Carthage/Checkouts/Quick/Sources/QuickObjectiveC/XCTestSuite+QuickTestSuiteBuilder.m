#import <XCTest/XCTest.h>
#import <objc/runtime.h>

#if __has_include("Quick-Swift.h")
#import "Quick-Swift.h"
#else
#import <Quick/Quick-Swift.h>
#endif

@interface XCTestSuite (QuickTestSuiteBuilder)
@end

@implementation XCTestSuite (QuickTestSuiteBuilder)

/**
 In order to ensure we can correctly build dynamic test suites, we need to
 replace some of the default test suite constructors.
 */
+ (void)load {
    Method testCaseWithName = class_getClassMethod(self, @selector(testSuiteForTestCaseWithName:));
    Method hooked_testCaseWithName = class_getClassMethod(self, @selector(qck_hooked_testSuiteForTestCaseWithName:));
    method_exchangeImplementations(testCaseWithName, hooked_testCaseWithName);
}

/**
 The `+testSuiteForTestCaseWithName:` method is called when a specific test case
 class is run from the Xcode test navigator. If the built test suite is `nil`,
 Xcode will not run any tests for that test case.

 Given if the following test case class is run from the Xcode test navigator:

    FooSpec
        testFoo
        testBar

 XCTest will invoke this once per test case, with test case names following this format:

    FooSpec/testFoo
    FooSpec/testBar
 */
+ (nullable instancetype)qck_hooked_testSuiteForTestCaseWithName:(nonnull NSString *)name {
    return [QuickTestSuite selectedTestSuiteForTestCaseWithName:name];
}

@end
