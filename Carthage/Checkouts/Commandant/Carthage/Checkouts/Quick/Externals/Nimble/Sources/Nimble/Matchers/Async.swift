import Foundation
import Dispatch

/// If you are running on a slower machine, it could be useful to increase the default timeout value
/// or slow down poll interval. Default timeout interval is 1, and poll interval is 0.01.
public struct AsyncDefaults {
    public static var timeout: DispatchTimeInterval = .seconds(1)
    public static var pollInterval: DispatchTimeInterval = .milliseconds(10)
}

extension AsyncDefaults {
    @available(*, unavailable, renamed: "timeout")
    public static var Timeout: TimeInterval = 1
    @available(*, unavailable, renamed: "pollInterval")
    public static var PollInterval: TimeInterval = 0.01
}

private func async<T>(style: ExpectationStyle, predicate: Predicate<T>, timeout: DispatchTimeInterval, poll: DispatchTimeInterval, fnName: String) -> Predicate<T> {
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
        case .timedOut:
            let message = lastPredicateResult?.message ?? .fail("timed out before returning a value")
            return PredicateResult(status: .fail, message: message)
        case let .errorThrown(error):
            return PredicateResult(status: .fail, message: .fail("unexpected error thrown: <\(error)>"))
        case let .raisedException(exception):
            return PredicateResult(status: .fail, message: .fail("unexpected exception raised: \(exception)"))
        case .blockedRunLoop:
            // swiftlint:disable:next line_length
            let message = lastPredicateResult?.message.appended(message: " (timed out, but main run loop was unresponsive).") ??
                .fail("main run loop was unresponsive")
            return PredicateResult(status: .fail, message: message)
        case .incomplete:
            internalError("Reached .incomplete state for \(fnName)(...).")
        }
    }
}

private let toEventuallyRequiresClosureError = FailureMessage(
    stringValue: """
        expect(...).toEventually(...) requires an explicit closure (eg - expect { ... }.toEventually(...) )
        Swift 1.2 @autoclosure behavior has changed in an incompatible way for Nimble to function
        """
)

extension Expectation {
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    public func toEventually(_ predicate: Predicate<T>, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) {
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
    public func toEventuallyNot(_ predicate: Predicate<T>, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) {
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
    public func toNotEventually(_ predicate: Predicate<T>, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil) {
        return toEventuallyNot(predicate, timeout: timeout, pollInterval: pollInterval, description: description)
    }
}

@available(*, deprecated, message: "Use Predicate instead")
extension Expectation {
    /// Tests the actual value using a matcher to match by checking continuously
    /// at each pollInterval until the timeout is reached.
    ///
    /// @discussion
    /// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
    /// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
    public func toEventually<U>(_ matcher: U, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil)
        where U: Matcher, U.ValueType == T {
        if expression.isClosure {
            let (pass, msg) = execute(
                expression,
                .toMatch,
                async(
                    style: .toMatch,
                    predicate: matcher.predicate,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventually"
                ),
                to: "to eventually",
                description: description,
                captureExceptions: false
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
    public func toEventuallyNot<U>(_ matcher: U, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil)
        where U: Matcher, U.ValueType == T {
        if expression.isClosure {
            let (pass, msg) = expressionDoesNotMatch(
                expression,
                matcher: async(
                    style: .toNotMatch,
                    predicate: matcher.predicate,
                    timeout: timeout,
                    poll: pollInterval,
                    fnName: "toEventuallyNot"
                ),
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
    public func toNotEventually<U>(_ matcher: U, timeout: DispatchTimeInterval = AsyncDefaults.timeout, pollInterval: DispatchTimeInterval = AsyncDefaults.pollInterval, description: String? = nil)
        where U: Matcher, U.ValueType == T {
        return toEventuallyNot(matcher, timeout: timeout, pollInterval: pollInterval, description: description)
    }
}
