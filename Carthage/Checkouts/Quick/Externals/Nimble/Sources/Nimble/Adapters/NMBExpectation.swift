import Foundation

#if canImport(Darwin) && !SWIFT_PACKAGE

private func from(objcPredicate: NMBPredicate) -> Predicate<NSObject> {
    return Predicate { actualExpression in
        let result = objcPredicate.satisfies(({ try actualExpression.evaluate() }),
                                             location: actualExpression.location)
        return result.toSwift()
    }
}

internal struct ObjCMatcherWrapper: Matcher {
    let matcher: NMBMatcher

    func matches(_ actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool {
        return matcher.matches(
            // swiftlint:disable:next force_try
            ({ try! actualExpression.evaluate() }),
            failureMessage: failureMessage,
            location: actualExpression.location)
    }

    func doesNotMatch(_ actualExpression: Expression<NSObject>, failureMessage: FailureMessage) -> Bool {
        return matcher.doesNotMatch(
            // swiftlint:disable:next force_try
            ({ try! actualExpression.evaluate() }),
            failureMessage: failureMessage,
            location: actualExpression.location)
    }
}

// Equivalent to Expectation, but for Nimble's Objective-C interface
public class NMBExpectation: NSObject {
    // swiftlint:disable identifier_name
    internal let _actualBlock: () -> NSObject?
    internal var _negative: Bool
    internal let _file: FileString
    internal let _line: UInt
    internal var _timeout: TimeInterval = 1.0
    // swiftlint:enable identifier_name

    @objc public init(actualBlock: @escaping () -> NSObject?, negative: Bool, file: FileString, line: UInt) {
        self._actualBlock = actualBlock
        self._negative = negative
        self._file = file
        self._line = line
    }

    private var expectValue: Expectation<NSObject> {
        return expect(_file, line: _line) {
            self._actualBlock() as NSObject?
        }
    }

    @objc public var withTimeout: (TimeInterval) -> NMBExpectation {
        return { timeout in self._timeout = timeout
            return self
        }
    }

    @objc public var to: (NMBMatcher) -> Void {
        return { matcher in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.to(from(objcPredicate: pred))
            } else {
                self.expectValue.to(ObjCMatcherWrapper(matcher: matcher))
            }
        }
    }

    @objc public var toWithDescription: (NMBMatcher, String) -> Void {
        return { matcher, description in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.to(from(objcPredicate: pred), description: description)
            } else {
                self.expectValue.to(ObjCMatcherWrapper(matcher: matcher), description: description)
            }
        }
    }

    @objc public var toNot: (NMBMatcher) -> Void {
        return { matcher in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toNot(from(objcPredicate: pred))
            } else {
                self.expectValue.toNot(ObjCMatcherWrapper(matcher: matcher))
            }
        }
    }

    @objc public var toNotWithDescription: (NMBMatcher, String) -> Void {
        return { matcher, description in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toNot(from(objcPredicate: pred), description: description)
            } else {
                self.expectValue.toNot(ObjCMatcherWrapper(matcher: matcher), description: description)
            }
        }
    }

    @objc public var notTo: (NMBMatcher) -> Void { return toNot }

    @objc public var notToWithDescription: (NMBMatcher, String) -> Void { return toNotWithDescription }

    @objc public var toEventually: (NMBMatcher) -> Void {
        return { matcher in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toEventually(
                    from(objcPredicate: pred),
                    timeout: self._timeout,
                    description: nil
                )
            } else {
                self.expectValue.toEventually(
                    ObjCMatcherWrapper(matcher: matcher),
                    timeout: self._timeout,
                    description: nil
                )
            }
        }
    }

    @objc public var toEventuallyWithDescription: (NMBMatcher, String) -> Void {
        return { matcher, description in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toEventually(
                    from(objcPredicate: pred),
                    timeout: self._timeout,
                    description: description
                )
            } else {
                self.expectValue.toEventually(
                    ObjCMatcherWrapper(matcher: matcher),
                    timeout: self._timeout,
                    description: description
                )
            }
        }
    }

    @objc public var toEventuallyNot: (NMBMatcher) -> Void {
        return { matcher in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toEventuallyNot(
                    from(objcPredicate: pred),
                    timeout: self._timeout,
                    description: nil
                )
            } else {
                self.expectValue.toEventuallyNot(
                    ObjCMatcherWrapper(matcher: matcher),
                    timeout: self._timeout,
                    description: nil
                )
            }
        }
    }

    @objc public var toEventuallyNotWithDescription: (NMBMatcher, String) -> Void {
        return { matcher, description in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toEventuallyNot(
                    from(objcPredicate: pred),
                    timeout: self._timeout,
                    description: description
                )
            } else {
                self.expectValue.toEventuallyNot(
                    ObjCMatcherWrapper(matcher: matcher),
                    timeout: self._timeout,
                    description: description
                )
            }
        }
    }

    @objc public var toNotEventually: (NMBMatcher) -> Void {
        return toEventuallyNot
    }

    @objc public var toNotEventuallyWithDescription: (NMBMatcher, String) -> Void {
        return toEventuallyNotWithDescription
    }

    @objc public class func failWithMessage(_ message: String, file: FileString, line: UInt) {
        fail(message, location: SourceLocation(file: file, line: line))
    }
}

#endif
