#import <XCTest/XCTest.h>

#if __has_include("Nimble-Swift.h")
#import "Nimble-Swift.h"
#else
#import <Nimble/Nimble-Swift.h>
#endif

__attribute__((constructor))
static void registerCurrentTestCaseTracker(void) {
    [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:[CurrentTestCaseTracker sharedInstance]];
}
