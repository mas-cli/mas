public indirect enum ExpectationMessage {
    // --- Primary Expectations ---
    /// includes actual value in output ("expected to <message>, got <actual>")
    case expectedActualValueTo(/* message: */ String)
    /// uses a custom actual value string in output ("expected to <message>, got <actual>")
    case expectedCustomValueTo(/* message: */ String, actual: String)
    /// excludes actual value in output ("expected to <message>")
    case expectedTo(/* message: */ String)
    /// allows any free-form message ("<message>")
    case fail(/* message: */ String)

    // --- Composite Expectations ---
    // Generally, you'll want the methods, appended(message:) and appended(details:) instead.

    /// Not Fully Implemented Yet.
    case prepends(/* Prepended Message */ String, ExpectationMessage)

    /// appends after an existing message ("<expectation> (use beNil() to match nils)")
    case appends(ExpectationMessage, /* Appended Message */ String)

    /// provides long-form multi-line explainations ("<expectation>\n\n<string>")
    case details(ExpectationMessage, String)

    /// Returns the smallest message after the "expected to" string that summarizes the error.
    ///
    /// Returns the message part from ExpectationMessage, ignoring all .appends and .details.
    public var expectedMessage: String {
        switch self {
        case let .fail(msg):
            return msg
        case let .expectedTo(msg):
            return msg
        case let .expectedActualValueTo(msg):
            return msg
        case let .expectedCustomValueTo(msg, _):
            return msg
        case let .prepends(_, expectation):
            return expectation.expectedMessage
        case let .appends(expectation, msg):
            return "\(expectation.expectedMessage)\(msg)"
        case let .details(expectation, _):
            return expectation.expectedMessage
        }
    }

    /// Appends a message after the primary expectation message
    public func appended(message: String) -> ExpectationMessage {
        switch self {
        case .fail, .expectedTo, .expectedActualValueTo, .expectedCustomValueTo, .appends, .prepends:
            return .appends(self, message)
        case let .details(expectation, msg):
            return .details(expectation.appended(message: message), msg)
        }
    }

    /// Appends a message hinting to use beNil() for when the actual value given was nil.
    public func appendedBeNilHint() -> ExpectationMessage {
        return appended(message: " (use beNil() to match nils)")
    }

    /// Appends a detailed (aka - multiline) message after the primary expectation message
    /// Detailed messages will be placed after .appended(message:) calls.
    public func appended(details: String) -> ExpectationMessage {
        return .details(self, details)
    }

    internal func visitLeafs(_ f: (ExpectationMessage) -> ExpectationMessage) -> ExpectationMessage {
        // swiftlint:disable:previous identifier_name
        switch self {
        case .fail, .expectedTo, .expectedActualValueTo, .expectedCustomValueTo:
            return f(self)
        case let .prepends(msg, expectation):
            return .prepends(msg, expectation.visitLeafs(f))
        case let .appends(expectation, msg):
            return .appends(expectation.visitLeafs(f), msg)
        case let .details(expectation, msg):
            return .details(expectation.visitLeafs(f), msg)
        }
    }

    /// Replaces a primary expectation with one returned by f. Preserves all composite expectations
    /// that were built upon it (aka - all appended(message:) and appended(details:).
    public func replacedExpectation(_ f: @escaping (ExpectationMessage) -> ExpectationMessage) -> ExpectationMessage {
        // swiftlint:disable:previous identifier_name
        func walk(_ msg: ExpectationMessage) -> ExpectationMessage {
            switch msg {
            case .fail, .expectedTo, .expectedActualValueTo, .expectedCustomValueTo:
                return f(msg)
            default:
                return msg
            }
        }
        return visitLeafs(walk)
    }

    /// Wraps a primary expectation with text before and after it.
    /// Alias to prepended(message: before).appended(message: after)
    public func wrappedExpectation(before: String, after: String) -> ExpectationMessage {
        return prepended(expectation: before).appended(message: after)
    }

    /// Prepends a message by modifying the primary expectation
    public func prepended(expectation message: String) -> ExpectationMessage {
        func walk(_ msg: ExpectationMessage) -> ExpectationMessage {
            switch msg {
            case let .expectedTo(msg):
                return .expectedTo(message + msg)
            case let .expectedActualValueTo(msg):
                return .expectedActualValueTo(message + msg)
            case let .expectedCustomValueTo(msg, actual):
                return .expectedCustomValueTo(message + msg, actual: actual)
            default:
                return msg.visitLeafs(walk)
            }
        }
        return visitLeafs(walk)
    }

    // swiftlint:disable:next todo
    // TODO: test & verify correct behavior
    internal func prepended(message: String) -> ExpectationMessage {
        return .prepends(message, self)
    }

    /// Converts the tree of ExpectationMessages into a final built string.
    public func toString(actual: String, expected: String = "expected", to: String = "to") -> String {
        switch self {
        case let .fail(msg):
            return msg
        case let .expectedTo(msg):
            return "\(expected) \(to) \(msg)"
        case let .expectedActualValueTo(msg):
            return "\(expected) \(to) \(msg), got \(actual)"
        case let .expectedCustomValueTo(msg, actual):
            return "\(expected) \(to) \(msg), got \(actual)"
        case let .prepends(msg, expectation):
            return "\(msg)\(expectation.toString(actual: actual, expected: expected, to: to))"
        case let .appends(expectation, msg):
            return "\(expectation.toString(actual: actual, expected: expected, to: to))\(msg)"
        case let .details(expectation, msg):
            return "\(expectation.toString(actual: actual, expected: expected, to: to))\n\n\(msg)"
        }
    }

    // Backwards compatibility: converts ExpectationMessage tree to FailureMessage
    internal func update(failureMessage: FailureMessage) {
        switch self {
        case let .fail(msg) where !msg.isEmpty:
            failureMessage.stringValue = msg
        case .fail:
            break
        case let .expectedTo(msg):
            failureMessage.actualValue = nil
            failureMessage.postfixMessage = msg
        case let .expectedActualValueTo(msg):
            failureMessage.postfixMessage = msg
        case let .expectedCustomValueTo(msg, actual):
            failureMessage.postfixMessage = msg
            failureMessage.actualValue = actual
        case let .prepends(msg, expectation):
            expectation.update(failureMessage: failureMessage)
            if let desc = failureMessage.userDescription {
                failureMessage.userDescription = "\(msg)\(desc)"
            } else {
                failureMessage.userDescription = msg
            }
        case let .appends(expectation, msg):
            expectation.update(failureMessage: failureMessage)
            failureMessage.appendMessage(msg)
        case let .details(expectation, msg):
            expectation.update(failureMessage: failureMessage)
            failureMessage.appendDetails(msg)
        }
    }
}

extension FailureMessage {
    internal func toExpectationMessage() -> ExpectationMessage {
        let defaultMessage = FailureMessage()
        if expected != defaultMessage.expected || _stringValueOverride != nil {
            return .fail(stringValue)
        }

        var message: ExpectationMessage = .fail(userDescription ?? "")
        if actualValue != "" && actualValue != nil {
            message = .expectedCustomValueTo(postfixMessage, actual: actualValue ?? "")
        } else if postfixMessage != defaultMessage.postfixMessage {
            if actualValue == nil {
                message = .expectedTo(postfixMessage)
            } else {
                message = .expectedActualValueTo(postfixMessage)
            }
        }
        if postfixActual != defaultMessage.postfixActual {
            message = .appends(message, postfixActual)
        }
        if let extended = extendedMessage {
            message = .details(message, extended)
        }
        return message
    }
}

#if canImport(Darwin)
import class Foundation.NSObject

public class NMBExpectationMessage: NSObject {
    private let msg: ExpectationMessage

    internal init(swift msg: ExpectationMessage) {
        self.msg = msg
    }

    public init(expectedTo message: String) {
        self.msg = .expectedTo(message)
    }
    public init(expectedActualValueTo message: String) {
        self.msg = .expectedActualValueTo(message)
    }

    public init(expectedActualValueTo message: String, customActualValue actual: String) {
        self.msg = .expectedCustomValueTo(message, actual: actual)
    }

    public init(fail message: String) {
        self.msg = .fail(message)
    }

    public init(prepend message: String, child: NMBExpectationMessage) {
        self.msg = .prepends(message, child.msg)
    }

    public init(appendedMessage message: String, child: NMBExpectationMessage) {
        self.msg = .appends(child.msg, message)
    }

    public init(prependedMessage message: String, child: NMBExpectationMessage) {
        self.msg = .prepends(message, child.msg)
    }

    public init(details message: String, child: NMBExpectationMessage) {
        self.msg = .details(child.msg, message)
    }

    public func appendedBeNilHint() -> NMBExpectationMessage {
        return NMBExpectationMessage(swift: msg.appendedBeNilHint())
    }

    public func toSwift() -> ExpectationMessage { return self.msg }
}

extension ExpectationMessage {
    func toObjectiveC() -> NMBExpectationMessage {
        return NMBExpectationMessage(swift: self)
    }
}

#endif
