import XCTest

extension AllPassTest {
    static let __allTests = [
        ("testAllPassArray", testAllPassArray),
        ("testAllPassCollectionsWithOptionalsDontWork", testAllPassCollectionsWithOptionalsDontWork),
        ("testAllPassCollectionsWithOptionalsUnwrappingOneOptionalLayer", testAllPassCollectionsWithOptionalsUnwrappingOneOptionalLayer),
        ("testAllPassMatcher", testAllPassMatcher),
        ("testAllPassSet", testAllPassSet),
        ("testAllPassWithNilAsExpectedValue", testAllPassWithNilAsExpectedValue),
    ]
}

extension AsyncTest {
    static let __allTests = [
        ("testCombiningAsyncWaitUntilAndToEventuallyIsNotAllowed", testCombiningAsyncWaitUntilAndToEventuallyIsNotAllowed),
        ("testSubjectUnderTestIsReleasedFromMemory", testSubjectUnderTestIsReleasedFromMemory),
        ("testToEventuallyMustBeInMainThread", testToEventuallyMustBeInMainThread),
        ("testToEventuallyNegativeMatches", testToEventuallyNegativeMatches),
        ("testToEventuallyPositiveMatches", testToEventuallyPositiveMatches),
        ("testToEventuallyWithCustomDefaultTimeout", testToEventuallyWithCustomDefaultTimeout),
        ("testWaitUntilDetectsStalledMainThreadActivity", testWaitUntilDetectsStalledMainThreadActivity),
        ("testWaitUntilErrorsIfDoneIsCalledMultipleTimes", testWaitUntilErrorsIfDoneIsCalledMultipleTimes),
        ("testWaitUntilMustBeInMainThread", testWaitUntilMustBeInMainThread),
        ("testWaitUntilNegativeMatches", testWaitUntilNegativeMatches),
        ("testWaitUntilPositiveMatches", testWaitUntilPositiveMatches),
        ("testWaitUntilTimesOutIfNotCalled", testWaitUntilTimesOutIfNotCalled),
        ("testWaitUntilTimesOutWhenExceedingItsTime", testWaitUntilTimesOutWhenExceedingItsTime),
        ("testWaitUntilWithCustomDefaultsTimeout", testWaitUntilWithCustomDefaultsTimeout),
    ]
}

extension BeAKindOfObjCTest {
    static let __allTests = [
        ("testFailureMessages", testFailureMessages),
        ("testPositiveMatch", testPositiveMatch),
    ]
}

extension BeAKindOfSwiftTest {
    static let __allTests = [
        ("testFailureMessages", testFailureMessages),
        ("testPositiveMatch", testPositiveMatch),
    ]
}

extension BeAnInstanceOfTest {
    static let __allTests = [
        ("testFailureMessages", testFailureMessages),
        ("testFailureMessagesSwiftTypes", testFailureMessagesSwiftTypes),
        ("testPositiveMatch", testPositiveMatch),
        ("testPositiveMatchSwiftTypes", testPositiveMatchSwiftTypes),
    ]
}

extension BeCloseToTest {
    static let __allTests = [
        ("testBeCloseTo", testBeCloseTo),
        ("testBeCloseToArray", testBeCloseToArray),
        ("testBeCloseToOperator", testBeCloseToOperator),
        ("testBeCloseToOperatorWithDate", testBeCloseToOperatorWithDate),
        ("testBeCloseToWithCGFloat", testBeCloseToWithCGFloat),
        ("testBeCloseToWithDate", testBeCloseToWithDate),
        ("testBeCloseToWithin", testBeCloseToWithin),
        ("testBeCloseToWithinOperator", testBeCloseToWithinOperator),
        ("testBeCloseToWithinOperatorWithDate", testBeCloseToWithinOperatorWithDate),
        ("testBeCloseToWithNSDate", testBeCloseToWithNSDate),
        ("testBeCloseToWithNSNumber", testBeCloseToWithNSNumber),
        ("testPlusMinusOperator", testPlusMinusOperator),
        ("testPlusMinusOperatorWithDate", testPlusMinusOperatorWithDate),
    ]
}

extension BeEmptyTest {
    static let __allTests = [
        ("testBeEmptyNegative", testBeEmptyNegative),
        ("testBeEmptyPositive", testBeEmptyPositive),
        ("testNilMatches", testNilMatches),
    ]
}

extension BeFalseTest {
    static let __allTests = [
        ("testShouldMatchFalse", testShouldMatchFalse),
        ("testShouldNotMatchNilBools", testShouldNotMatchNilBools),
        ("testShouldNotMatchTrue", testShouldNotMatchTrue),
    ]
}

extension BeFalsyTest {
    static let __allTests = [
        ("testShouldMatchFalse", testShouldMatchFalse),
        ("testShouldMatchNilBools", testShouldMatchNilBools),
        ("testShouldMatchNilTypes", testShouldMatchNilTypes),
        ("testShouldNotMatchNonNilTypes", testShouldNotMatchNonNilTypes),
        ("testShouldNotMatchTrue", testShouldNotMatchTrue),
    ]
}

extension BeGreaterThanOrEqualToTest {
    static let __allTests = [
        ("testGreaterThanOrEqualTo", testGreaterThanOrEqualTo),
        ("testGreaterThanOrEqualToOperator", testGreaterThanOrEqualToOperator),
    ]
}

extension BeGreaterThanTest {
    static let __allTests = [
        ("testGreaterThan", testGreaterThan),
        ("testGreaterThanOperator", testGreaterThanOperator),
    ]
}

extension BeIdenticalToObjectTest {
    static let __allTests = [
        ("testBeIdenticalToNegative", testBeIdenticalToNegative),
        ("testBeIdenticalToNegativeMessage", testBeIdenticalToNegativeMessage),
        ("testBeIdenticalToPositive", testBeIdenticalToPositive),
        ("testBeIdenticalToPositiveMessage", testBeIdenticalToPositiveMessage),
        ("testFailsOnNils", testFailsOnNils),
        ("testOperators", testOperators),
    ]
}

extension BeIdenticalToTest {
    static let __allTests = [
        ("testBeAlias", testBeAlias),
        ("testBeIdenticalToNegative", testBeIdenticalToNegative),
        ("testBeIdenticalToNegativeMessage", testBeIdenticalToNegativeMessage),
        ("testBeIdenticalToPositive", testBeIdenticalToPositive),
        ("testBeIdenticalToPositiveMessage", testBeIdenticalToPositiveMessage),
        ("testOperators", testOperators),
    ]
}

extension BeLessThanOrEqualToTest {
    static let __allTests = [
        ("testLessThanOrEqualTo", testLessThanOrEqualTo),
        ("testLessThanOrEqualToOperator", testLessThanOrEqualToOperator),
    ]
}

extension BeLessThanTest {
    static let __allTests = [
        ("testLessThan", testLessThan),
        ("testLessThanOperator", testLessThanOperator),
    ]
}

extension BeNilTest {
    static let __allTests = [
        ("testBeNil", testBeNil),
    ]
}

extension BeTrueTest {
    static let __allTests = [
        ("testShouldMatchTrue", testShouldMatchTrue),
        ("testShouldNotMatchFalse", testShouldNotMatchFalse),
        ("testShouldNotMatchNilBools", testShouldNotMatchNilBools),
    ]
}

extension BeTruthyTest {
    static let __allTests = [
        ("testShouldMatchBoolConvertibleTypesThatConvertToTrue", testShouldMatchBoolConvertibleTypesThatConvertToTrue),
        ("testShouldMatchNonNilTypes", testShouldMatchNonNilTypes),
        ("testShouldMatchTrue", testShouldMatchTrue),
        ("testShouldNotMatchBoolConvertibleTypesThatConvertToFalse", testShouldNotMatchBoolConvertibleTypesThatConvertToFalse),
        ("testShouldNotMatchFalse", testShouldNotMatchFalse),
        ("testShouldNotMatchNilBools", testShouldNotMatchNilBools),
        ("testShouldNotMatchNilTypes", testShouldNotMatchNilTypes),
    ]
}

extension BeVoidTest {
    static let __allTests = [
        ("testBeVoid", testBeVoid),
    ]
}

extension BeginWithTest {
    static let __allTests = [
        ("testNegativeMatches", testNegativeMatches),
        ("testPositiveMatches", testPositiveMatches),
    ]
}

extension ContainElementSatisfyingTest {
    static let __allTests = [
        ("testContainElementSatisfying", testContainElementSatisfying),
        ("testContainElementSatisfyingDefaultErrorMessage", testContainElementSatisfyingDefaultErrorMessage),
        ("testContainElementSatisfyingNegativeCase", testContainElementSatisfyingNegativeCase),
        ("testContainElementSatisfyingNegativeCaseDefaultErrorMessage", testContainElementSatisfyingNegativeCaseDefaultErrorMessage),
        ("testContainElementSatisfyingNegativeCaseSpecificErrorMessage", testContainElementSatisfyingNegativeCaseSpecificErrorMessage),
        ("testContainElementSatisfyingSpecificErrorMessage", testContainElementSatisfyingSpecificErrorMessage),
    ]
}

extension ContainTest {
    static let __allTests = [
        ("testCollectionArguments", testCollectionArguments),
        ("testContainObjCSubstring", testContainObjCSubstring),
        ("testContainSequence", testContainSequence),
        ("testContainSequenceAndSetAlgebra", testContainSequenceAndSetAlgebra),
        ("testContainSetAlgebra", testContainSetAlgebra),
        ("testContainSubstring", testContainSubstring),
        ("testVariadicArguments", testVariadicArguments),
    ]
}

extension ElementsEqualTest {
    static let __allTests = [
        ("testSequenceElementsEquality", testSequenceElementsEquality),
    ]
}

extension EndWithTest {
    static let __allTests = [
        ("testEndWithNegatives", testEndWithNegatives),
        ("testEndWithPositives", testEndWithPositives),
    ]
}

extension EqualTest {
    static let __allTests = [
        ("testArrayEquality", testArrayEquality),
        ("testArrayOfOptionalsEquality", testArrayOfOptionalsEquality),
        ("testDataEquality", testDataEquality),
        ("testDictionariesWithDifferentSequences", testDictionariesWithDifferentSequences),
        ("testDictionaryEquality", testDictionaryEquality),
        ("testDoesNotMatchNils", testDoesNotMatchNils),
        ("testEquality", testEquality),
        ("testNSObjectEquality", testNSObjectEquality),
        ("testOperatorEquality", testOperatorEquality),
        ("testOperatorEqualityWithArrays", testOperatorEqualityWithArrays),
        ("testOperatorEqualityWithDictionaries", testOperatorEqualityWithDictionaries),
        ("testOptionalEquality", testOptionalEquality),
        ("testSetEquality", testSetEquality),
    ]
}

extension HaveCountTest {
    static let __allTests = [
        ("testHaveCountForArray", testHaveCountForArray),
        ("testHaveCountForDictionary", testHaveCountForDictionary),
        ("testHaveCountForSet", testHaveCountForSet),
    ]
}

extension MatchErrorTest {
    static let __allTests = [
        ("testDoesNotMatchNils", testDoesNotMatchNils),
        ("testMatchErrorNegative", testMatchErrorNegative),
        ("testMatchErrorPositive", testMatchErrorPositive),
        ("testMatchNegativeMessage", testMatchNegativeMessage),
        ("testMatchNSErrorNegative", testMatchNSErrorNegative),
        ("testMatchNSErrorPositive", testMatchNSErrorPositive),
        ("testMatchPositiveMessage", testMatchPositiveMessage),
    ]
}

extension MatchTest {
    static let __allTests = [
        ("testMatchNegative", testMatchNegative),
        ("testMatchNegativeMessage", testMatchNegativeMessage),
        ("testMatchNils", testMatchNils),
        ("testMatchPositive", testMatchPositive),
        ("testMatchPositiveMessage", testMatchPositiveMessage),
    ]
}

extension PostNotificationTest {
    static let __allTests = [
        ("testFailsWhenNoNotificationsArePosted", testFailsWhenNoNotificationsArePosted),
        ("testFailsWhenNotificationWithWrongNameIsPosted", testFailsWhenNotificationWithWrongNameIsPosted),
        ("testFailsWhenNotificationWithWrongObjectIsPosted", testFailsWhenNotificationWithWrongObjectIsPosted),
        ("testPassesWhenAllExpectedNotificationsArePosted", testPassesWhenAllExpectedNotificationsArePosted),
        ("testPassesWhenExpectedNotificationEventuallyIsPosted", testPassesWhenExpectedNotificationEventuallyIsPosted),
        ("testPassesWhenExpectedNotificationIsPosted", testPassesWhenExpectedNotificationIsPosted),
        ("testPassesWhenNoNotificationsArePosted", testPassesWhenNoNotificationsArePosted),
    ]
}

extension SatisfyAllOfTest {
    static let __allTests = [
        ("testOperatorAnd", testOperatorAnd),
        ("testSatisfyAllOf", testSatisfyAllOf),
    ]
}

extension SatisfyAnyOfTest {
    static let __allTests = [
        ("testOperatorOr", testOperatorOr),
        ("testSatisfyAnyOf", testSatisfyAnyOf),
    ]
}

extension SynchronousTest {
    static let __allTests = [
        ("testFailAlwaysFails", testFailAlwaysFails),
        ("testNotToMatchesLikeToNot", testNotToMatchesLikeToNot),
        ("testToMatchAgainstLazyProperties", testToMatchAgainstLazyProperties),
        ("testToMatchesIfMatcherReturnsTrue", testToMatchesIfMatcherReturnsTrue),
        ("testToNegativeMatches", testToNegativeMatches),
        ("testToNotMatchesIfMatcherReturnsTrue", testToNotMatchesIfMatcherReturnsTrue),
        ("testToNotNegativeMatches", testToNotNegativeMatches),
        ("testToNotProvidesActualValueExpression", testToNotProvidesActualValueExpression),
        ("testToNotProvidesAMemoizedActualValueExpression", testToNotProvidesAMemoizedActualValueExpression),
        ("testToNotProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl", testToNotProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl),
        ("testToProvidesActualValueExpression", testToProvidesActualValueExpression),
        ("testToProvidesAMemoizedActualValueExpression", testToProvidesAMemoizedActualValueExpression),
        ("testToProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl", testToProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl),
        ("testUnexpectedErrorsThrownFails", testUnexpectedErrorsThrownFails),
    ]
}

extension ThrowErrorTest {
    static let __allTests = [
        ("testNegativeMatches", testNegativeMatches),
        ("testNegativeMatchesDoNotCallClosureWithoutError", testNegativeMatchesDoNotCallClosureWithoutError),
        ("testNegativeMatchesWithClosure", testNegativeMatchesWithClosure),
        ("testNegativeNegatedMatches", testNegativeNegatedMatches),
        ("testPositiveMatches", testPositiveMatches),
        ("testPositiveMatchesWithClosures", testPositiveMatchesWithClosures),
        ("testPositiveNegatedMatches", testPositiveNegatedMatches),
    ]
}

extension ToSucceedTest {
    static let __allTests = [
        ("testToSucceed", testToSucceed),
    ]
}

extension UserDescriptionTest {
    static let __allTests = [
        ("testNotToMatcher_CustomFailureMessage", testNotToMatcher_CustomFailureMessage),
        ("testToEventuallyMatch_CustomFailureMessage", testToEventuallyMatch_CustomFailureMessage),
        ("testToEventuallyNotMatch_CustomFailureMessage", testToEventuallyNotMatch_CustomFailureMessage),
        ("testToMatcher_CustomFailureMessage", testToMatcher_CustomFailureMessage),
        ("testToNotEventuallyMatch_CustomFailureMessage", testToNotEventuallyMatch_CustomFailureMessage),
        ("testToNotMatcher_CustomFailureMessage", testToNotMatcher_CustomFailureMessage),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AllPassTest.__allTests),
        testCase(AsyncTest.__allTests),
        testCase(BeAKindOfObjCTest.__allTests),
        testCase(BeAKindOfSwiftTest.__allTests),
        testCase(BeAnInstanceOfTest.__allTests),
        testCase(BeCloseToTest.__allTests),
        testCase(BeEmptyTest.__allTests),
        testCase(BeFalseTest.__allTests),
        testCase(BeFalsyTest.__allTests),
        testCase(BeGreaterThanOrEqualToTest.__allTests),
        testCase(BeGreaterThanTest.__allTests),
        testCase(BeIdenticalToObjectTest.__allTests),
        testCase(BeIdenticalToTest.__allTests),
        testCase(BeLessThanOrEqualToTest.__allTests),
        testCase(BeLessThanTest.__allTests),
        testCase(BeNilTest.__allTests),
        testCase(BeTrueTest.__allTests),
        testCase(BeTruthyTest.__allTests),
        testCase(BeVoidTest.__allTests),
        testCase(BeginWithTest.__allTests),
        testCase(ContainElementSatisfyingTest.__allTests),
        testCase(ContainTest.__allTests),
        testCase(ElementsEqualTest.__allTests),
        testCase(EndWithTest.__allTests),
        testCase(EqualTest.__allTests),
        testCase(HaveCountTest.__allTests),
        testCase(MatchErrorTest.__allTests),
        testCase(MatchTest.__allTests),
        testCase(PostNotificationTest.__allTests),
        testCase(SatisfyAllOfTest.__allTests),
        testCase(SatisfyAnyOfTest.__allTests),
        testCase(SynchronousTest.__allTests),
        testCase(ThrowErrorTest.__allTests),
        testCase(ToSucceedTest.__allTests),
        testCase(UserDescriptionTest.__allTests),
    ]
}
#endif
