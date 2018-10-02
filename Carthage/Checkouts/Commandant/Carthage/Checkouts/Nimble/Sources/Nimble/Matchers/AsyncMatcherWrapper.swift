import Foundation

/// If you are running on a slower machine, it could be useful to increase the default timeout value
/// or slow down poll interval. Default timeout interval is 1, and poll interval is 0.01.
public struct AsyncDefaults {
    public static var Timeout: TimeInterval = 1
    public static var PollInterval: TimeInterval = 0.01
}

private func async<T>(style: ExpectationStyle, predicate: Predicate<T>, timeout: TimeInterval, poll: TimeInterval, fnName: String) -> Predicate<T> {
    return Predicate { actualExpression in
        let uncachedExpression = actualExpression.withoutCaching()
        let fnName = "expect(...).\(fnName)(...)"
        var lastPredicateResult: PredicateResult?
        let result = pollBlock(
            pollInterval: poll,
            timeoutInterval: timeout,
            file: actualExpression.location.file,
            line: actualExpression.location.line,
            fnName: fnName) {
                lastPredicateResult = try predicate.satisfies(uncachedExpression)
                return lastPredicateResult!.toBoolean(expectation: style)
        }
        switch result {
        case .completed: return lastPredicateResult!
        case .timedOut: return PredicateResult(status: .fail, message: lastPredicateResult!.message)
        case let .errorThrown(error):
            return PredicateResult(status: .fail, message: .fail("unexpected error thrown: <\(error)>"))
        case let .raisedException(exception):
            return PredicateResult(status: .fail, message: .fail("unexpected exception raised: \(exception)"))
        case .blockedRunLoop:
            // swiftlint:disable:next line_length
            return PredicateResult(status: .fail, message: lastPredicateResult!.message.appended(message: " (timed out, but main thread was unresponsive)."))
        case .incomplete:
            internalError("Reached .incomplete state for toEventually(...).")
        }
    }
}

// Deprecated
internal struct AsyncMatcherWrapper<T, U>: Matcher
    where U: Matcher, U.ValueType == T {
    let fullMatcher: U
    let timeoutInterval: TimeInterval
    let pollInterval: TimeInterval

    init(fullMatcher: U, timeoutInterval: TimeInterval = AsyncDefaults.Timeout, pollInterval: TimeInterval = AsyncDefaults.PollInterval) {
      self.fullMatcher = fullMatcher
      self.timeoutInterval = timeoutInterval
      self.pollInterval = pollInterval
    }

    func matches(_ actualExpression: Expression<T>, failureMessage: FailureMessage) -> Bool {
        let uncachedExpression = actualExpression.withoutCaching()
        let fnName = "expect(...).toEventually(...)"
        let result = pollBlock(
            pollInterval: pollInterval,
            timeoutInterval: timeoutInterval,
            file: actualExpression.location.file,
            line: actualExpression.location.line,
            fnName: fnName) {
                try self.fullMatcher.matches(uncachedExpression, failureMessage: failureMessage)
        }
        switch result {
        case let .completed(isSuccessful): return isSuccessful
        case .timedOut: return false
        case let .errorThrown(error):
            failureMessage.stringValue = "an unexpected error thrown: <\(error)>"
            return false
        case let .raisedException(exception):
            failureMessage.stringValue = "an unexpected exception thrown: <\(exception)>"
            return false
        case .blockedRunLoop:
            failureMessage.postfixMessage += " (timed out, but main thread was unresponsive)."
            return false
        case .incomplete:
            internalError("Reached .incomplete state for toEventually(...).")
        }
    }

    func doesNotMatch(_ actualExpression: Expression<T>, failureMessage: FailureMessage) -> Bool {
        let uncachedExpression = actualExpression.withoutCaching()
        let result = pollBlock(
            pollInterval: pollInterval,
            timeoutInterval: timeoutInterval,
            file: actualExpression.location.file,
            line: actualExpression.location.line,
            fnName: "expect(...).toEventuallyNot(...)") {
                try self.fullMatcher.doesNotMatch(uncachedExpression, failureMessage: failureMessage)
        }
        switch result {
        case let .completed(isSuccessful): return isSuccessful
        case .timedOut: return false
        case let .errorThrown(error):
            failureMessage.stringValue = "an unexpected error thrown: <\(error)>"
            return false
        case let .raisedException(exception):
            failureMessage.stringValue = "an unexpected exception thrown: <\(exception)>"
            return false
        case .blockedRunLoop:
            failureMessage.postfixMessage += " (timed out, but main thread was unresponsive)."
            return false
        case .incomplete:
            internalError("Reached .incomplete state for toEventuallyNot(...).")
        }
    }
}

private let toEventuallyRequiresClosureError = FailureMessage(
    // swiftlint:disable:next line_length
    stringValue: "expect(...).toEventually(...) requires an explicit closure (eg - expect { ... }.toEventually(...) )\nSwift 1.2 @autoclosure behavior has changed in an incompatible way for Nimble to function"
)

extension Expectation {
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    public func toEventually(_ predicate: Predicate<T>, timeout: TimeInterval = AsyncDefaults.Timeout, pollInterval: TimeInterval = AsyncDefaults.PollInterval, description: String? = nil) {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toMatch,
            async(style: .toMatch, predicate: predicate, timeout: timeout, poll: pollInterval, fnName: "toEventually"),
            to: "to eventually",
            description: description,
            captureExceptions: false
        )
        verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    public func toEventuallyNot(_ predicate: Predicate<T>, timeout: TimeInterval = AsyncDefaults.Timeout, pollInterval: TimeInterval = AsyncDefaults.PollInterval, description: String? = nil) {
        nimblePrecondition(expression.isClosure, "NimbleInternalError", toEventuallyRequiresClosureError.stringValue)

        let (pass, msg) = execute(
            expression,
            .toNotMatch,
            async(
                style: .toNotMatch,
                predicate: predicate,
                timeout: timeout,
                poll: pollInterval,
                fnName: "toEventuallyNot"
            ),
            to: "to eventually not",
            description: description,
            captureExceptions: false
        )
        verify(pass, msg)
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    public func toNotEventually(_ predicate: Predicate<T>, timeout: TimeInterval = AsyncDefaults.Timeout, pollInterval: TimeInterval = AsyncDefaults.PollInterval, description: String? = nil) {
        return toEventuallyNot(predicate, timeout: timeout, pollInterval: pollInterval, description: description)
    }
}

// Deprecated
extension Expectation {
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    public func toEventually<U>(_ matcher: U, timeout: TimeInterval = AsyncDefaults.Timeout, pollInterval: TimeInterval = AsyncDefaults.PollInterval, description: String? = nil)
        where U: Matcher, U.ValueType == T {
        if expression.isClosure {
            let (pass, msg) = expressionMatches(
                expression,
                matcher: AsyncMatcherWrapper(
                    fullMatcher: matcher,
                    timeoutInterval: timeout,
                    pollInterval: pollInterval),
                to: "to eventually",
                description: description
            )
            verify(pass, msg)
        } else {
            verify(false, toEventuallyRequiresClosureError)
        }
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    public func toEventuallyNot<U>(_ matcher: U, timeout: TimeInterval = AsyncDefaults.Timeout, pollInterval: TimeInterval = AsyncDefaults.PollInterval, description: String? = nil)
        where U: Matcher, U.ValueType == T {
        if expression.isClosure {
            let (pass, msg) = expressionDoesNotMatch(
                expression,
                matcher: AsyncMatcherWrapper(
                    fullMatcher: matcher,
                    timeoutInterval: timeout,
                    pollInterval: pollInterval),
                toNot: "to eventually not",
                description: description
            )
            verify(pass, msg)
        } else {
            verify(false, toEventuallyRequiresClosureError)
        }
    }

    /// Tests the actual value using a matcher to not match by checking
    /// continuously at each pollInterval until the timeout is reached.
    ///
    /// Alias of toEventuallyNot()
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    public func toNotEventually<U>(_ matcher: U, timeout: TimeInterval = AsyncDefaults.Timeout, pollInterval: TimeInterval = AsyncDefaults.PollInterval, description: String? = nil)
        where U: Matcher, U.ValueType == T {
        return toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }
}
