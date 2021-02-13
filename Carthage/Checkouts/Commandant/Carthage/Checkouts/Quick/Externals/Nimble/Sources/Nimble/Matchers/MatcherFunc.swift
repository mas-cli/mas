/// DEPRECATED: A convenience API to build matchers that don't need special negation
/// behavior. The toNot() behavior is the negation of to().
///
/// @see NonNilMatcherFunc if you prefer to have this matcher fail when nil
///                        values are received in an expectation.
///
/// You may use this when implementing your own custom matchers.
///
/// Use the Matcher protocol instead of this type to accept custom matchers as
/// input parameters.
/// @see allPass for an example that uses accepts other matchers as input.
@available(*, deprecated, message: "Use Predicate instead")
public struct MatcherFunc<T>: Matcher {
    public let matcher: (Expression<T>, FailureMessage) throws -> Bool

    public init(_ matcher: @escaping (Expression<T>, FailureMessage) throws -> Bool) {
        self.matcher = matcher
    }

    public func matches(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        return try matcher(actualExpression, failureMessage)
    }

    public func doesNotMatch(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        return try !matcher(actualExpression, failureMessage)
    }

    /// Compatibility layer to new Matcher API. Converts an old-style matcher to a new one.
    /// Note: You should definitely spend the time to convert to the new api as soon as possible
    /// since this struct type is deprecated.
    @available(*, deprecated, message: "Use Predicate directly instead")
    public var predicate: Predicate<T> {
        return Predicate.fromDeprecatedMatcher(self)
    }
}

/// DEPRECATED: A convenience API to build matchers that don't need special negation
/// behavior. The toNot() behavior is the negation of to().
///
/// Unlike MatcherFunc, this will always fail if an expectation contains nil.
/// This applies regardless of using to() or toNot().
///
/// You may use this when implementing your own custom matchers.
///
/// Use the Matcher protocol instead of this type to accept custom matchers as
/// input parameters.
/// @see allPass for an example that uses accepts other matchers as input.
@available(*, deprecated, message: "Use Predicate instead")
public struct NonNilMatcherFunc<T>: Matcher {
    public let matcher: (Expression<T>, FailureMessage) throws -> Bool

    public init(_ matcher: @escaping (Expression<T>, FailureMessage) throws -> Bool) {
        self.matcher = matcher
    }

    public func matches(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        let pass = try matcher(actualExpression, failureMessage)
        if try attachNilErrorIfNeeded(actualExpression, failureMessage: failureMessage) {
            return false
        }
        return pass
    }

    public func doesNotMatch(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        let pass = try !matcher(actualExpression, failureMessage)
        if try attachNilErrorIfNeeded(actualExpression, failureMessage: failureMessage) {
            return false
        }
        return pass
    }

    internal func attachNilErrorIfNeeded(_ actualExpression: Expression<T>, failureMessage: FailureMessage) throws -> Bool {
        if try actualExpression.evaluate() == nil {
            failureMessage.postfixActual = " (use beNil() to match nils)"
            return true
        }
        return false
    }

    /// Compatibility layer to new Matcher API. Converts an old-style matcher to a new one.
    /// Note: You should definitely spend the time to convert to the new api as soon as possible
    /// since this struct type is deprecated.
    @available(*, deprecated, message: "Use Predicate directly instead")
    public var predicate: Predicate<T> {
        return Predicate.fromDeprecatedMatcher(self)
    }
}
