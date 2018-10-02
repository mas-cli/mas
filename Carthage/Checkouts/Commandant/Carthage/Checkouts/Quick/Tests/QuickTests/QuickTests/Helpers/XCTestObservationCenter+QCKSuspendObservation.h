#import <XCTest/XCTest.h>

/**
 Add the ability to temporarily disable internal XCTest execution observation in
 order to run isolated XCTestSuite instances while the QuickTests test suite is running.
 */
@interface XCTestObservationCenter (QCKSuspendObservation)

/**
 Suspends test suite observation for XCTest-provided observers for the duration that
 the block is executing. Any test suites that are executed within the block do not 
 generate any log output. Failures are still reported.

 Use this method to run XCTestSuite objects while another XCTestSuite is running.
 Without this method, tests fail with the message: "Timed out waiting for IDE
 barrier message to complete" or "Unexpected TestSuiteDidStart".
 */
- (void)qck_suspendObservationForBlock:(void (^)(void))block;

@end
