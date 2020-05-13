import Foundation

extension Int8: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).int8Value
    }
}

extension UInt8: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).uint8Value
    }
}

extension Int16: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).int16Value
    }
}

extension UInt16: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).uint16Value
    }
}

extension Int32: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).int32Value
    }
}

extension UInt32: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).uint32Value
    }
}

extension Int64: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).int64Value
    }
}

extension UInt64: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).uint64Value
    }
}

extension Float: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).floatValue
    }
}

extension Double: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).doubleValue
    }
}

extension Int: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).intValue
    }
}

extension UInt: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = NSNumber(value: value).uintValue
    }
}

internal func rename<T>(_ matcher: Predicate<T>, failureMessage message: ExpectationMessage) -> Predicate<T> {
    return Predicate { actualExpression in
        let result = try matcher.satisfies(actualExpression)
        return PredicateResult(status: result.status, message: message)
    }.requireNonNil
}

// MARK: beTrue() / beFalse()

/// A Nimble matcher that succeeds when the actual value is exactly true.
/// This matcher will not match against nils.
public func beTrue() -> Predicate<Bool> {
    return rename(equal(true), failureMessage: .expectedActualValueTo("be true"))
}

/// A Nimble matcher that succeeds when the actual value is exactly false.
/// This matcher will not match against nils.
public func beFalse() -> Predicate<Bool> {
    return rename(equal(false), failureMessage: .expectedActualValueTo("be false"))
}

// MARK: beTruthy() / beFalsy()

/// A Nimble matcher that succeeds when the actual value is not logically false.
public func beTruthy<T: ExpressibleByBooleanLiteral & Equatable>() -> Predicate<T> {
    return Predicate.simpleNilable("be truthy") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        if let actualValue = actualValue {
            return PredicateStatus(bool: actualValue == (true as T))
        }
        return PredicateStatus(bool: actualValue != nil)
    }
}

/// A Nimble matcher that succeeds when the actual value is logically false.
/// This matcher will match against nils.
public func beFalsy<T: ExpressibleByBooleanLiteral & Equatable>() -> Predicate<T> {
    return Predicate.simpleNilable("be falsy") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        if let actualValue = actualValue {
            return PredicateStatus(bool: actualValue == (false as T))
        }
        return PredicateStatus(bool: actualValue == nil)
    }
}

#if canImport(Darwin)
extension NMBObjCMatcher {
    @objc public class func beTruthyMatcher() -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let expr = actualExpression.cast { ($0 as? NSNumber)?.boolValue ?? false }
            return try beTruthy().satisfies(expr).toObjectiveC()
        }
    }

    @objc public class func beFalsyMatcher() -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let expr = actualExpression.cast { ($0 as? NSNumber)?.boolValue ?? false }
            return try beFalsy().satisfies(expr).toObjectiveC()
        }
    }

    @objc public class func beTrueMatcher() -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let expr = actualExpression.cast { ($0 as? NSNumber)?.boolValue ?? false }
            return try beTrue().satisfies(expr).toObjectiveC()
        }
    }

    @objc public class func beFalseMatcher() -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let expr = actualExpression.cast { value -> Bool? in
                guard let value = value else { return nil }
                return (value as? NSNumber)?.boolValue ?? false
            }
            return try beFalse().satisfies(expr).toObjectiveC()
        }
    }
}
#endif
