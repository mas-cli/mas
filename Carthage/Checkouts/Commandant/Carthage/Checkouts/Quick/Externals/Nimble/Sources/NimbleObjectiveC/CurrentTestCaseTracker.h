#import <XCTest/XCTest.h>

#if __has_include("Nimble-Swift.h")
#import "Nimble-Swift.h"
#else
#import <Nimble/Nimble-Swift.h>
#endif

SWIFT_CLASS("_TtC6Nimble22CurrentTestCaseTracker")
@interface CurrentTestCaseTracker : NSObject <XCTestObservation>
+ (CurrentTestCaseTracker *)sharedInstance;
@end

@interface CurrentTestCaseTracker (Register) @end
