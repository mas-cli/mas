// This matcher requires the Objective-C, and being built by Xcode rather than the Swift Package Manager
#if canImport(Darwin) && !SWIFT_PACKAGE
import class Foundation.NSObject
import class Foundation.NSDictionary
import class Foundation.NSException

/// A Nimble matcher that succeeds when the actual expression raises an
/// exception with the specified name, reason, and/or userInfo.
///
/// Alternatively, you can pass a closure to do any arbitrary custom matching
/// to the raised exception. The closure only gets called when an exception
/// is raised.
///
/// nil arguments indicates that the matcher should not attempt to match against
/// that parameter.
public func raiseException<Out>(
    named: NSExceptionName? = nil,
    reason: String? = nil,
    userInfo: NSDictionary? = nil,
    closure: ((NSException) -> Void)? = nil
) -> Predicate<Out> {
    return raiseException(named: named?.rawValue, reason: reason, userInfo: userInfo, closure: closure)
}

/// A Nimble matcher that succeeds when the actual expression raises an
/// exception with the specified name, reason, and/or userInfo.
///
/// Alternatively, you can pass a closure to do any arbitrary custom matching
/// to the raised exception. The closure only gets called when an exception
/// is raised.
///
/// nil arguments indicates that the matcher should not attempt to match against
/// that parameter.
public func raiseException<Out>(
    named: String?,
    reason: String? = nil,
    userInfo: NSDictionary? = nil,
    closure: ((NSException) -> Void)? = nil
) -> Predicate<Out> {
    return Predicate { actualExpression in
        var exception: NSException?
        let capture = NMBExceptionCapture(handler: ({ e in
            exception = e
        }), finally: nil)

        do {
            try capture.tryBlockThrows {
                _ = try actualExpression.evaluate()
            }
        } catch {
            return PredicateResult(status: .fail, message: .fail("unexpected error thrown: <\(error)>"))
        }

        let message = messageForException(
            exception: exception,
            named: named,
            reason: reason,
            userInfo: userInfo,
            closure: closure
        )

        let matches = exceptionMatchesNonNilFieldsOrClosure(
            exception,
            named: named,
            reason: reason,
            userInfo: userInfo,
            closure: closure
        )
        return PredicateResult(bool: matches, message: message)
    }
}

internal func messageForException(
    exception: NSException?,
    named: String?,
    reason: String?,
    userInfo: NSDictionary?,
    closure: ((NSException) -> Void)?
) -> ExpectationMessage {
    var rawMessage: String = "raise exception"

    if let named = named {
        rawMessage += " with name <\(named)>"
    }
    if let reason = reason {
        rawMessage += " with reason <\(reason)>"
    }
    if let userInfo = userInfo {
        rawMessage += " with userInfo <\(userInfo)>"
    }
    if closure != nil {
        rawMessage += " that satisfies block"
    }
    if named == nil && reason == nil && userInfo == nil && closure == nil {
        rawMessage = "raise any exception"
    }

    let actual: String
    if let exception = exception {
        // swiftlint:disable:next line_length
        actual = "\(String(describing: type(of: exception))) { name=\(exception.name), reason='\(stringify(exception.reason))', userInfo=\(stringify(exception.userInfo)) }"
    } else {
        actual = "no exception"
    }

    return .expectedCustomValueTo(rawMessage, actual: actual)
}

internal func exceptionMatchesNonNilFieldsOrClosure(
    _ exception: NSException?,
    named: String?,
    reason: String?,
    userInfo: NSDictionary?,
    closure: ((NSException) -> Void)?) -> Bool {
        var matches = false

        if let exception = exception {
            matches = true

            if let named = named, exception.name.rawValue != named {
                matches = false
            }
            if reason != nil && exception.reason != reason {
                matches = false
            }
            if let userInfo = userInfo, let exceptionUserInfo = exception.userInfo,
                (exceptionUserInfo as NSDictionary) != userInfo {
                matches = false
            }
            if let closure = closure {
                let assertions = gatherFailingExpectations {
                    closure(exception)
                }
                let messages = assertions.map { $0.message }
                if messages.count > 0 {
                    matches = false
                }
            }
        }

        return matches
}

public class NMBObjCRaiseExceptionPredicate: NMBPredicate {
    private let _name: String?
    private let _reason: String?
    private let _userInfo: NSDictionary?
    private let _block: ((NSException) -> Void)?

    fileprivate init(name: String?, reason: String?, userInfo: NSDictionary?, block: ((NSException) -> Void)?) {
        _name = name
        _reason = reason
        _userInfo = userInfo
        _block = block

        let predicate: Predicate<NSObject> = raiseException(
            named: name,
            reason: reason,
            userInfo: userInfo,
            closure: block
        )
        let predicateBlock: PredicateBlock = { actualExpression in
            return try predicate.satisfies(actualExpression).toObjectiveC()
        }
        super.init(predicate: predicateBlock)
    }

    @objc public var named: (_ name: String) -> NMBObjCRaiseExceptionPredicate {
        let (reason, userInfo, block) = (_reason, _userInfo, _block)
        return { name in
            return NMBObjCRaiseExceptionPredicate(
                name: name,
                reason: reason,
                userInfo: userInfo,
                block: block
            )
        }
    }

    @objc public var reason: (_ reason: String?) -> NMBObjCRaiseExceptionPredicate {
        let (name, userInfo, block) = (_name, _userInfo, _block)
        return { reason in
            return NMBObjCRaiseExceptionPredicate(
                name: name,
                reason: reason,
                userInfo: userInfo,
                block: block
            )
        }
    }

    @objc public var userInfo: (_ userInfo: NSDictionary?) -> NMBObjCRaiseExceptionPredicate {
        let (name, reason, block) = (_name, _reason, _block)
        return { userInfo in
            return NMBObjCRaiseExceptionPredicate(
                name: name,
                reason: reason,
                userInfo: userInfo,
                block: block
            )
        }
    }

    @objc public var satisfyingBlock: (_ block: ((NSException) -> Void)?) -> NMBObjCRaiseExceptionPredicate {
        let (name, reason, userInfo) = (_name, _reason, _userInfo)
        return { block in
            return NMBObjCRaiseExceptionPredicate(
                name: name,
                reason: reason,
                userInfo: userInfo,
                block: block
            )
        }
    }
}

extension NMBPredicate {
    @objc public class func raiseExceptionMatcher() -> NMBObjCRaiseExceptionPredicate {
        return NMBObjCRaiseExceptionPredicate(name: nil, reason: nil, userInfo: nil, block: nil)
    }
}
#endif
