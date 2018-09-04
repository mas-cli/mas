import Foundation
// `CGFloat` is in Foundation (swift-corelibs-foundation) on Linux.
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import CoreGraphics
#endif

/// Implement this protocol to implement a custom matcher for Swift
@available(*, deprecated, message: "Use Predicate instead")
public protocol Matcher {
    associatedtype ValueType
    func matches(_ actualExpression: Expression<ValueType>, failureMessage: FailureMessage) throws -> Bool
    func doesNotMatch(_ actualExpression: Expression<ValueType>, failureMessage: FailureMessage) throws -> Bool
}

extension Matcher {
    var predicate: Predicate<ValueType> {
        return Predicate.fromDeprecatedMatcher(self)
    }

    var toClosure: (Expression<ValueType>, FailureMessage, Bool) throws -> Bool {
        return ({ expr, msg, expectedResult in
            if expectedResult {
                return try self.matches(expr, failureMessage: msg)
            } else {
                return try self.doesNotMatch(expr, failureMessage: msg)
            }
        })
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
/// Objective-C interface to the Swift variant of Matcher.
@objc public protocol NMBMatcher {
    func matches(_ actualBlock: @escaping () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool
    func doesNotMatch(_ actualBlock: @escaping () -> NSObject!, failureMessage: FailureMessage, location: SourceLocation) -> Bool
}
#endif

/// Protocol for types that support contain() matcher.
public protocol NMBContainer {
    func contains(_ anObject: Any) -> Bool
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
// FIXME: NSHashTable can not conform to NMBContainer since swift-DEVELOPMENT-SNAPSHOT-2016-04-25-a
//extension NSHashTable : NMBContainer {} // Corelibs Foundation does not include this class yet
#endif

extension NSArray: NMBContainer {}
extension NSSet: NMBContainer {}

/// Protocol for types that support only beEmpty(), haveCount() matchers
public protocol NMBCollection {
    var count: Int { get }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NSHashTable: NMBCollection {} // Corelibs Foundation does not include these classes yet
extension NSMapTable: NMBCollection {}
#endif

extension NSSet: NMBCollection {}
extension NSIndexSet: NMBCollection {}
extension NSDictionary: NMBCollection {}

/// Protocol for types that support beginWith(), endWith(), beEmpty() matchers
public protocol NMBOrderedCollection: NMBCollection {
    func object(at index: Int) -> Any
}

extension NSArray: NMBOrderedCollection {}

public protocol NMBDoubleConvertible {
    var doubleValue: CDouble { get }
}

extension Double: NMBDoubleConvertible {
    public var doubleValue: CDouble {
        return self
    }
}

extension Float: NMBDoubleConvertible {
    public var doubleValue: CDouble {
        return CDouble(self)
    }
}

extension CGFloat: NMBDoubleConvertible {
    public var doubleValue: CDouble {
        return CDouble(self)
    }
}

extension NSNumber: NMBDoubleConvertible {
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")

    return formatter
}()

extension Date: NMBDoubleConvertible {
    public var doubleValue: CDouble {
        return self.timeIntervalSinceReferenceDate
    }
}

extension NSDate: NMBDoubleConvertible {
    public var doubleValue: CDouble {
        return self.timeIntervalSinceReferenceDate
    }
}

extension Date: TestOutputStringConvertible {
    public var testDescription: String {
        return dateFormatter.string(from: self)
    }
}

extension NSDate: TestOutputStringConvertible {
    public var testDescription: String {
        return dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: self.timeIntervalSinceReferenceDate))
    }
}

/// Protocol for types to support beLessThan(), beLessThanOrEqualTo(),
///  beGreaterThan(), beGreaterThanOrEqualTo(), and equal() matchers.
///
/// Types that conform to Swift's Comparable protocol will work implicitly too
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
@objc public protocol NMBComparable {
    func NMB_compare(_ otherObject: NMBComparable!) -> ComparisonResult
}
#else
// This should become obsolete once Corelibs Foundation adds Comparable conformance to NSNumber
public protocol NMBComparable {
    func NMB_compare(_ otherObject: NMBComparable!) -> ComparisonResult
}
#endif

extension NSNumber: NMBComparable {
    public func NMB_compare(_ otherObject: NMBComparable!) -> ComparisonResult {
        return compare(otherObject as! NSNumber)
    }
}
extension NSString: NMBComparable {
    public func NMB_compare(_ otherObject: NMBComparable!) -> ComparisonResult {
        return compare(otherObject as! String)
    }
}
