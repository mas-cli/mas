@import Quick;

#if __has_include("QuickTests-Swift.h")
#import "QuickTests-Swift.h"
#elif __has_include("QuickFocusedTests-Swift.h")
#import "QuickFocusedTests-Swift.h"
#endif

#import "QCKSpecRunner.h"

XCTestRun *qck_runSpec(Class specClass) {
    return [QCKSpecRunner runSpec:specClass];
}

XCTestRun * _Nullable qck_runSpecs(NSArray * _Nonnull specClasses) {
    return [QCKSpecRunner runSpecs:specClasses];
}
