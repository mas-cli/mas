// Generic

internal func messageForError<T: Error>(
    postfixMessageVerb: String = "throw",
    actualError: Error?,
    error: T? = nil,
    errorType: T.Type? = nil,
    closure: ((T) -> Void)? = nil
) -> ExpectationMessage {
    var rawMessage = "\(postfixMessageVerb) error"

    if let error = error {
        rawMessage += " <\(error)>"
    } else if errorType != nil || closure != nil {
        rawMessage += " from type <\(T.self)>"
    }
    if closure != nil {
        rawMessage += " that satisfies block"
    }
    if error == nil && errorType == nil && closure == nil {
        rawMessage = "\(postfixMessageVerb) any error"
    }

    let actual: String
    if let actualError = actualError {
        actual = "<\(actualError)>"
    } else {
        actual = "no error"
    }

    return .expectedCustomValueTo(rawMessage, actual: actual)
}

internal func errorMatchesExpectedError<T: Error>(
    _ actualError: Error,
    expectedError: T) -> Bool {
    return actualError._domain == expectedError._domain
        && actualError._code   == expectedError._code
}

// Non-generic

internal func messageForError(
    actualError: Error?,
    closure: ((Error) -> Void)?
) -> ExpectationMessage {
    var rawMessage = "throw error"

    if closure != nil {
        rawMessage += " that satisfies block"
    } else {
        rawMessage = "throw any error"
    }

    let actual: String
    if let actualError = actualError {
        actual = "<\(actualError)>"
    } else {
        actual = "no error"
    }

    return .expectedCustomValueTo(rawMessage, actual: actual)
}
