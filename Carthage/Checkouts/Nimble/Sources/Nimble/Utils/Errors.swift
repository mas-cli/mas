import Foundation

// Generic

internal func setFailureMessageForError<T: Error>(
    _ failureMessage: FailureMessage,
    postfixMessageVerb: String = "throw",
    actualError: Error?,
    error: T? = nil,
    errorType: T.Type? = nil,
    closure: ((T) -> Void)? = nil) {
    failureMessage.postfixMessage = "\(postfixMessageVerb) error"

    if let error = error {
        failureMessage.postfixMessage += " <\(error)>"
    } else if errorType != nil || closure != nil {
        failureMessage.postfixMessage += " from type <\(T.self)>"
    }
    if closure != nil {
        failureMessage.postfixMessage += " that satisfies block"
    }
    if error == nil && errorType == nil && closure == nil {
        failureMessage.postfixMessage = "\(postfixMessageVerb) any error"
    }

    if let actualError = actualError {
        failureMessage.actualValue = "<\(actualError)>"
    } else {
        failureMessage.actualValue = "no error"
    }
}

internal func errorMatchesExpectedError<T: Error>(
    _ actualError: Error,
    expectedError: T) -> Bool {
    return actualError._domain == expectedError._domain
        && actualError._code   == expectedError._code
}

// Non-generic

internal func setFailureMessageForError(
    _ failureMessage: FailureMessage,
    actualError: Error?,
    closure: ((Error) -> Void)?) {
    failureMessage.postfixMessage = "throw error"

    if closure != nil {
        failureMessage.postfixMessage += " that satisfies block"
    } else {
        failureMessage.postfixMessage = "throw any error"
    }

    if let actualError = actualError {
        failureMessage.actualValue = "<\(actualError)>"
    } else {
        failureMessage.actualValue = "no error"
    }
}
