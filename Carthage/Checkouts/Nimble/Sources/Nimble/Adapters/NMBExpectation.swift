#if canImport(Darwin) && !SWIFT_PACKAGE
import class Foundation.NSObject
import typealias Foundation.TimeInterval
import enum Dispatch.DispatchTimeInterval

private func from(objcPredicate: NMBPredicate) -> Predicate<NSObject> {
    return Predicate { actualExpression in
        let result = objcPredicate.satisfies(({ try actualExpression.evaluate() }),
                                             location: actualExpression.location)
        return result.toSwift()
    }
}

private func from(matcher: NMBMatcher, style: ExpectationStyle) -> Predicate<NSObject> {
    // Almost same as `Matcher.toClosure`
    let closure: (Expression<NSObject>, FailureMessage) throws -> Bool = { expr, msg in
        switch style {
        case .toMatch:
            return matcher.matches(
                // swiftlint:disable:next force_try
                ({ try! expr.evaluate() }),
                failureMessage: msg,
                location: expr.location
            )
        case .toNotMatch:
            return !matcher.doesNotMatch(
                // swiftlint:disable:next force_try
                ({ try! expr.evaluate() }),
                failureMessage: msg,
                location: expr.location
            )
        }
    }
    return Predicate._fromDeprecatedClosure(closure)
}

// Equivalent to Expectation, but for Nimble's Objective-C interface
public class NMBExpectation: NSObject {
    // swiftlint:disable identifier_name
    internal let _actualBlock: () -> NSObject?
    internal var _negative: Bool
    internal let _file: FileString
    internal let _line: UInt
    internal var _timeout: DispatchTimeInterval = .seconds(1)
    // swiftlint:enable identifier_name

    @objc public init(actualBlock: @escaping () -> NSObject?, negative: Bool, file: FileString, line: UInt) {
        self._actualBlock = actualBlock
        self._negative = negative
        self._file = file
        self._line = line
    }

    private var expectValue: Expectation<NSObject> {
        return expect(file: _file, line: _line, self._actualBlock() as NSObject?)
    }

    @objc public var withTimeout: (TimeInterval) -> NMBExpectation {
        return { timeout in self._timeout = timeout.dispatchInterval
            return self
        }
    }

    @objc public var to: (NMBMatcher) -> NMBExpectation {
        return { matcher in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.to(from(objcPredicate: pred))
            } else {
                self.expectValue.to(from(matcher: matcher, style: .toMatch))
            }
            return self
        }
    }

    @objc public var toWithDescription: (NMBMatcher, String) -> NMBExpectation {
        return { matcher, description in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.to(from(objcPredicate: pred), description: description)
            } else {
                self.expectValue.to(from(matcher: matcher, style: .toMatch), description: description)
            }
            return self
        }
    }

    @objc public var toNot: (NMBMatcher) -> NMBExpectation {
        return { matcher in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toNot(from(objcPredicate: pred))
            } else {
                self.expectValue.toNot(from(matcher: matcher, style: .toNotMatch))
            }
            return self
        }
    }

    @objc public var toNotWithDescription: (NMBMatcher, String) -> NMBExpectation {
        return { matcher, description in
            if let pred = matcher as? NMBPredicate {
                self.expectValue.toNot(from(objcPredicate: pred), description: description)
            } else {
                self.expectValue.toNot(from(matcher: matcher, style: .toNotMatch), description: description)
            }
            return self
        }
    }

    @objc public var notTo: (NMBMatcher) -> NMBExpectation { return toNot }

    @objc public var notToWithDescription: (NMBMatcher, String) -> NMBExpectation { return toNotWithDescription }

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
                    from(matcher: matcher, style: .toMatch),
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
                    from(matcher: matcher, style: .toMatch),
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
                    from(matcher: matcher, style: .toNotMatch),
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
                    from(matcher: matcher, style: .toNotMatch),
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
