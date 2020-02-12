import Foundation

/// Make an expectation on a given actual value. The value given is lazily evaluated.
public func expect<T>(_ expression: @autoclosure @escaping () throws -> T?, file: FileString = #file, line: UInt = #line) -> Expectation<T> {
    return Expectation(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Make an expectation on a given actual value. The closure is lazily invoked.
public func expect<T>(_ file: FileString = #file, line: UInt = #line, expression: @escaping () throws -> T?) -> Expectation<T> {
    return Expectation(
        expression: Expression(
            expression: expression,
            location: SourceLocation(file: file, line: line),
            isClosure: true))
}

/// Always fails the test with a message and a specified location.
public func fail(_ message: String, location: SourceLocation) {
    let handler = NimbleEnvironment.activeInstance.assertionHandler
    handler.assert(false, message: FailureMessage(stringValue: message), location: location)
}

/// Always fails the test with a message.
public func fail(_ message: String, file: FileString = #file, line: UInt = #line) {
    fail(message, location: SourceLocation(file: file, line: line))
}

/// Always fails the test.
public func fail(_ file: FileString = #file, line: UInt = #line) {
    fail("fail() always fails", file: file, line: line)
}

/// Like Swift's precondition(), but raises NSExceptions instead of sigaborts
internal func nimblePrecondition(
    _ expr: @autoclosure() -> Bool,
    _ name: @autoclosure() -> String,
    _ message: @autoclosure() -> String,
    file: StaticString = #file,
    line: UInt = #line) {
        let result = expr()
        if !result {
#if canImport(Darwin)
            let exception = NSException(
                name: NSExceptionName(name()),
                reason: message(),
                userInfo: nil
            )
            exception.raise()
#else
            preconditionFailure("\(name()) - \(message())", file: file, line: line)
#endif
        }
}

internal func internalError(_ msg: String, file: FileString = #file, line: UInt = #line) -> Never {
    // swiftlint:disable line_length
    fatalError(
        """
        Nimble Bug Found: \(msg) at \(file):\(line).
        Please file a bug to Nimble: https://github.com/Quick/Nimble/issues with the code snippet that caused this error.
        """
    )
    // swiftlint:enable line_length
}
