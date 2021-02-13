#import <XCTest/XCTest.h>

#if __has_include("Nimble-Swift.h")
#import "Nimble-Swift.h"
#else
#import <Nimble/Nimble-Swift.h>
#endif

#pragma mark - Private

@implementation XCTestObservationCenter (Register)

+ (void)load {
    [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:[CurrentTestCaseTracker sharedInstance]];
}

@end
