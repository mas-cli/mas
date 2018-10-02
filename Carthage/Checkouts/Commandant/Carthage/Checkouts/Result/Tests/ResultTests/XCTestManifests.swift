import XCTest

extension AnyErrorTests {
    static let __allTests = [
        ("testAnyError", testAnyError),
    ]
}

extension NoErrorTests {
    static let __allTests = [
        ("testEquatable", testEquatable),
    ]
}

extension ResultTests {
    static let __allTests = [
        ("testAnyErrorDelegatesLocalizedDescriptionToUnderlyingError", testAnyErrorDelegatesLocalizedDescriptionToUnderlyingError),
        ("testAnyErrorDelegatesLocalizedFailureReasonToUnderlyingError", testAnyErrorDelegatesLocalizedFailureReasonToUnderlyingError),
        ("testAnyErrorDelegatesLocalizedHelpAnchorToUnderlyingError", testAnyErrorDelegatesLocalizedHelpAnchorToUnderlyingError),
        ("testAnyErrorDelegatesLocalizedRecoverySuggestionToUnderlyingError", testAnyErrorDelegatesLocalizedRecoverySuggestionToUnderlyingError),
        ("testBimapTransformsFailures", testBimapTransformsFailures),
        ("testBimapTransformsSuccesses", testBimapTransformsSuccesses),
        ("testErrorsIncludeTheCallingFunction", testErrorsIncludeTheCallingFunction),
        ("testErrorsIncludeTheSourceFile", testErrorsIncludeTheSourceFile),
        ("testErrorsIncludeTheSourceLine", testErrorsIncludeTheSourceLine),
        ("testFanout", testFanout),
        ("testInitOptionalFailure", testInitOptionalFailure),
        ("testInitOptionalSuccess", testInitOptionalSuccess),
        ("testMapRewrapsFailures", testMapRewrapsFailures),
        ("testMapTransformsSuccesses", testMapTransformsSuccesses),
        ("testMaterializeInferrence", testMaterializeInferrence),
        ("testMaterializeProducesFailures", testMaterializeProducesFailures),
        ("testMaterializeProducesSuccesses", testMaterializeProducesSuccesses),
        ("testRecoverProducesLeftForLeftSuccess", testRecoverProducesLeftForLeftSuccess),
        ("testRecoverProducesRightForLeftFailure", testRecoverProducesRightForLeftFailure),
        ("testRecoverWithProducesLeftForLeftSuccess", testRecoverWithProducesLeftForLeftSuccess),
        ("testRecoverWithProducesRightFailureForLeftFailureAndRightFailure", testRecoverWithProducesRightFailureForLeftFailureAndRightFailure),
        ("testRecoverWithProducesRightSuccessForLeftFailureAndRightSuccess", testRecoverWithProducesRightSuccessForLeftFailureAndRightSuccess),
        ("testTryCatchProducesFailures", testTryCatchProducesFailures),
        ("testTryCatchProducesSuccesses", testTryCatchProducesSuccesses),
        ("testTryCatchWithFunctionCatchProducesFailures", testTryCatchWithFunctionCatchProducesFailures),
        ("testTryCatchWithFunctionProducesSuccesses", testTryCatchWithFunctionProducesSuccesses),
        ("testTryCatchWithFunctionThrowingNonAnyErrorCanProducesAnyErrorFailures", testTryCatchWithFunctionThrowingNonAnyErrorCanProducesAnyErrorFailures),
        ("testTryMapProducesFailure", testTryMapProducesFailure),
        ("testTryMapProducesSuccess", testTryMapProducesSuccess),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AnyErrorTests.__allTests),
        testCase(NoErrorTests.__allTests),
        testCase(ResultTests.__allTests),
    ]
}
#endif
