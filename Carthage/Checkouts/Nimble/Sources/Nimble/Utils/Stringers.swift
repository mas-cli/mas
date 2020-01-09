import Foundation

internal func identityAsString(_ value: Any?) -> String {
    let anyObject: AnyObject?
#if os(Linux)
    #if swift(>=4.0)
        #if !swift(>=4.1.50)
            anyObject = value as? AnyObject
        #else
            anyObject = value as AnyObject?
        #endif
    #else
        #if !swift(>=3.4)
            anyObject = value as? AnyObject
        #else
            anyObject = value as AnyObject?
        #endif
    #endif
#else
    anyObject = value as AnyObject?
#endif
    if let value = anyObject {
        return NSString(format: "<%p>", unsafeBitCast(value, to: Int.self)).description
    } else {
        return "nil"
    }
}

internal func arrayAsString<T>(_ items: [T], joiner: String = ", ") -> String {
    return items.reduce("") { accum, item in
        let prefix = (accum.isEmpty ? "" : joiner)
        return accum + prefix + "\(stringify(item))"
    }
}

/// A type with a customized test output text representation.
///
/// This textual representation is produced when values will be
/// printed in test runs, and may be useful when producing
/// error messages in custom matchers.
///
/// - SeeAlso: `CustomDebugStringConvertible`
public protocol TestOutputStringConvertible {
    var testDescription: String { get }
}

extension Double: TestOutputStringConvertible {
    public var testDescription: String {
        return NSNumber(value: self).testDescription
    }
}

extension Float: TestOutputStringConvertible {
    public var testDescription: String {
        return NSNumber(value: self).testDescription
    }
}

extension NSNumber: TestOutputStringConvertible {
    // This is using `NSString(format:)` instead of
    // `String(format:)` because the latter somehow breaks
    // the travis CI build on linux.
    public var testDescription: String {
        let description = self.description

        if description.contains(".") {
            // Travis linux swiftpm build doesn't like casting String to NSString,
            // which is why this annoying nested initializer thing is here.
            // Maybe this will change in a future snapshot.
            let decimalPlaces = NSString(string: NSString(string: description)
                .components(separatedBy: ".")[1])

            // SeeAlso: https://bugs.swift.org/browse/SR-1464
            switch decimalPlaces.length {
            case 1:
                return NSString(format: "%0.1f", self.doubleValue).description
            case 2:
                return NSString(format: "%0.2f", self.doubleValue).description
            case 3:
                return NSString(format: "%0.3f", self.doubleValue).description
            default:
                return NSString(format: "%0.4f", self.doubleValue).description
            }
        }
        return self.description
    }
}

extension Array: TestOutputStringConvertible {
    public var testDescription: String {
        let list = self.map(Nimble.stringify).joined(separator: ", ")
        return "[\(list)]"
    }
}

extension AnySequence: TestOutputStringConvertible {
    public var testDescription: String {
        let generator = self.makeIterator()
        var strings = [String]()
        var value: AnySequence.Iterator.Element?

        repeat {
            value = generator.next()
            if let value = value {
                strings.append(stringify(value))
            }
        } while value != nil

        let list = strings.joined(separator: ", ")
        return "[\(list)]"
    }
}

extension NSArray: TestOutputStringConvertible {
    public var testDescription: String {
        let list = Array(self).map(Nimble.stringify).joined(separator: ", ")
        return "(\(list))"
    }
}

extension NSIndexSet: TestOutputStringConvertible {
    public var testDescription: String {
        let list = Array(self).map(Nimble.stringify).joined(separator: ", ")
        return "(\(list))"
    }
}

extension String: TestOutputStringConvertible {
    public var testDescription: String {
        return self
    }
}

extension Data: TestOutputStringConvertible {
    public var testDescription: String {
        #if os(Linux)
            // FIXME: Swift on Linux triggers a segfault when calling NSData's hash() (last checked on 03-11-16)
            return "Data<length=\(count)>"
        #else
            return "Data<hash=\((self as NSData).hash),length=\(count)>"
        #endif
    }
}

///
/// Returns a string appropriate for displaying in test output
/// from the provided value.
///
/// - parameter value: A value that will show up in a test's output.
///
/// - returns: The string that is returned can be
///     customized per type by conforming a type to the `TestOutputStringConvertible`
///     protocol. When stringifying a non-`TestOutputStringConvertible` type, this
///     function will return the value's debug description and then its
///     normal description if available and in that order. Otherwise it
///     will return the result of constructing a string from the value.
///
/// - SeeAlso: `TestOutputStringConvertible`
public func stringify<T>(_ value: T?) -> String {
    guard let value = value else { return "nil" }

    if let value = value as? TestOutputStringConvertible {
        return value.testDescription
    }

    if let value = value as? CustomDebugStringConvertible {
        return value.debugDescription
    }

    return String(describing: value)
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
@objc public class NMBStringer: NSObject {
    @objc public class func stringify(_ obj: Any?) -> String {
        return Nimble.stringify(obj)
    }
}
#endif

// MARK: Collection Type Stringers

/// Attempts to generate a pretty type string for a given value. If the value is of a Objective-C
/// collection type, or a subclass thereof, (e.g. `NSArray`, `NSDictionary`, etc.). 
/// This function will return the type name of the root class of the class cluster for better
/// readability (e.g. `NSArray` instead of `__NSArrayI`).
///
/// For values that don't have a type of an Objective-C collection, this function returns the
/// default type description.
///
/// - parameter value: A value that will be used to determine a type name.
///
/// - returns: The name of the class cluster root class for Objective-C collection types, or the
/// the `dynamicType` of the value for values of any other type.
public func prettyCollectionType<T>(_ value: T) -> String {
    switch value {
    case is NSArray:
        return String(describing: NSArray.self)
    case is NSDictionary:
        return String(describing: NSDictionary.self)
    case is NSSet:
        return String(describing: NSSet.self)
    case is NSIndexSet:
        return String(describing: NSIndexSet.self)
    default:
        return String(describing: value)
    }
}

/// Returns the type name for a given collection type. This overload is used by Swift
/// collection types.
///
/// - parameter collection: A Swift `CollectionType` value.
///
/// - returns: A string representing the `dynamicType` of the value.
public func prettyCollectionType<T: Collection>(_ collection: T) -> String {
    return String(describing: type(of: collection))
}
