import Foundation

/// A Nimble matcher that succeeds when the actual expression throws an
/// error of the specified type or from the specified case.
///
/// Errors are tried to be compared by their implementation of Equatable,
/// otherwise they fallback to comparison by _domain and _code.
///
/// Alternatively, you can pass a closure to do any arbitrary custom matching
/// to the thrown error. The closure only gets called when an error was thrown.
///
/// nil arguments indicates that the matcher should not attempt to match against
/// that parameter.
public func throwError() -> Predicate<Any> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in

        var actualError: Error?
        do {
            _ = try actualExpression.evaluate()
        } catch let catchedError {
            actualError = catchedError
        }

        failureMessage.postfixMessage = "throw any error"
        if let actualError = actualError {
            failureMessage.actualValue = "<\(actualError)>"
        } else {
            failureMessage.actualValue = "no error"
        }
        return actualError != nil
    }
}

/// A Nimble matcher that succeeds when the actual expression throws an
/// error of the specified type or from the specified case.
///
/// Errors are tried to be compared by their implementation of Equatable,
/// otherwise they fallback to comparision by _domain and _code.
///
/// Alternatively, you can pass a closure to do any arbitrary custom matching
/// to the thrown error. The closure only gets called when an error was thrown.
///
/// nil arguments indicates that the matcher should not attempt to match against
/// that parameter.
public func throwError<T: Error>(_ error: T, closure: ((Error) -> Void)? = nil) -> Predicate<Any> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in

        var actualError: Error?
        do {
            _ = try actualExpression.evaluate()
        } catch let catchedError {
            actualError = catchedError
        }

        setFailureMessageForError(
            failureMessage,
            actualError: actualError,
            error: error,
            errorType: nil,
            closure: closure
        )
        var matches = false
        if let actualError = actualError, errorMatchesExpectedError(actualError, expectedError: error) {
            matches = true
            if let closure = closure {
                let assertions = gatherFailingExpectations {
                    closure(actualError)
                }
                let messages = assertions.map { $0.message }
                if messages.count > 0 {
                    matches = false
                }
            }
        }
        return matches
    }
}

/// A Nimble matcher that succeeds when the actual expression throws an
/// error of the specified type or from the specified case.
///
/// Errors are tried to be compared by their implementation of Equatable,
/// otherwise they fallback to comparision by _domain and _code.
///
/// Alternatively, you can pass a closure to do any arbitrary custom matching
/// to the thrown error. The closure only gets called when an error was thrown.
///
/// nil arguments indicates that the matcher should not attempt to match against
/// that parameter.
public func throwError<T: Error & Equatable>(_ error: T, closure: ((T) -> Void)? = nil) -> Predicate<Any> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in

        var actualError: Error?
        do {
            _ = try actualExpression.evaluate()
        } catch let catchedError {
            actualError = catchedError
        }

        setFailureMessageForError(
            failureMessage,
            actualError: actualError,
            error: error,
            errorType: nil,
            closure: closure
        )
        var matches = false
        if let actualError = actualError as? T, error == actualError {
            matches = true

            if let closure = closure {
                let assertions = gatherFailingExpectations {
                    closure(actualError)
                }
                let messages = assertions.map { $0.message }
                if messages.count > 0 {
                    matches = false
                }
            }
        }
        return matches
    }
}

/// A Nimble matcher that succeeds when the actual expression throws an
/// error of the specified type or from the specified case.
///
/// Errors are tried to be compared by their implementation of Equatable,
/// otherwise they fallback to comparision by _domain and _code.
///
/// Alternatively, you can pass a closure to do any arbitrary custom matching
/// to the thrown error. The closure only gets called when an error was thrown.
///
/// nil arguments indicates that the matcher should not attempt to match against
/// that parameter.
public func throwError<T: Error>(
    errorType: T.Type,
    closure: ((T) -> Void)? = nil) -> Predicate<Any> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in

        var actualError: Error?
        do {
            _ = try actualExpression.evaluate()
        } catch let catchedError {
            actualError = catchedError
        }

        setFailureMessageForError(
            failureMessage,
            actualError: actualError,
            error: nil,
            errorType: errorType,
            closure: closure
        )
        var matches = false
        if let actualError = actualError {
            matches = true
            if let actualError = actualError as? T {
                if let closure = closure {
                    let assertions = gatherFailingExpectations {
                        closure(actualError)
                    }
                    let messages = assertions.map { $0.message }
                    if messages.count > 0 {
                        matches = false
                    }
                }
            } else {
                matches = (actualError is T)
                // The closure expects another ErrorProtocol as argument, so this
                // is _supposed_ to fail, so that it becomes more obvious.
                if let closure = closure {
                    let assertions = gatherExpectations {
                        if let actual = actualError as? T {
                            closure(actual)
                        }
                    }
                    let messages = assertions.map { $0.message }
                    if messages.count > 0 {
                        matches = false
                    }
                }
            }
        }

        return matches
    }
}

/// A Nimble matcher that succeeds when the actual expression throws any
/// error or when the passed closures' arbitrary custom matching succeeds.
///
/// This duplication to it's generic adequate is required to allow to receive
/// values of the existential type `Error` in the closure.
///
/// The closure only gets called when an error was thrown.
public func throwError(closure: @escaping ((Error) -> Void)) -> Predicate<Any> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in

        var actualError: Error?
        do {
            _ = try actualExpression.evaluate()
        } catch let catchedError {
            actualError = catchedError
        }

        setFailureMessageForError(failureMessage, actualError: actualError, closure: closure)

        var matches = false
        if let actualError = actualError {
            matches = true

            let assertions = gatherFailingExpectations {
                closure(actualError)
            }
            let messages = assertions.map { $0.message }
            if messages.count > 0 {
                matches = false
            }
        }
        return matches
    }
}

/// A Nimble matcher that succeeds when the actual expression throws any
/// error or when the passed closures' arbitrary custom matching succeeds.
///
/// This duplication to it's generic adequate is required to allow to receive
/// values of the existential type `Error` in the closure.
///
/// The closure only gets called when an error was thrown.
public func throwError<T: Error>(closure: @escaping ((T) -> Void)) -> Predicate<Any> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in

        var actualError: Error?
        do {
            _ = try actualExpression.evaluate()
        } catch let catchedError {
            actualError = catchedError
        }

        setFailureMessageForError(failureMessage, actualError: actualError, closure: closure)

        var matches = false
        if let actualError = actualError as? T {
            matches = true

            let assertions = gatherFailingExpectations {
                closure(actualError)
            }
            let messages = assertions.map { $0.message }
            if messages.count > 0 {
                matches = false
            }
        }
        return matches
    }
}
