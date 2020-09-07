import Foundation

#if canImport(Darwin)
// swiftlint:disable type_name
@objcMembers
public class _CallsiteBase: NSObject {}
#else
public class _CallsiteBase: NSObject {}
// swiftlint:enable type_name
#endif

// Ideally we would always use `StaticString` as the type for tracking the file name
// in which an example is defined, for consistency with `assert` etc. from the
// stdlib, and because recent versions of the XCTest overlay require `StaticString`
// when calling `XCTFail`. Under the Objective-C runtime (i.e. building on macOS), we
// have to use `String` instead because StaticString can't be generated from Objective-C
#if SWIFT_PACKAGE
public typealias FileString = StaticString
#else
public typealias FileString = String
#endif

/**
    An object encapsulating the file and line number at which
    a particular example is defined.
*/
final public class Callsite: _CallsiteBase {
    /**
        The absolute path of the file in which an example is defined.
    */
    public let file: FileString

    /**
        The line number on which an example is defined.
    */
    public let line: UInt

    internal init(file: FileString, line: UInt) {
        self.file = file
        self.line = line
    }
}

extension Callsite {
    /**
        Returns a boolean indicating whether two Callsite objects are equal.
        If two callsites are in the same file and on the same line, they must be equal.
    */
    @nonobjc public static func == (lhs: Callsite, rhs: Callsite) -> Bool {
        return String(describing: lhs.file) == String(describing: rhs.file) && lhs.line == rhs.line
    }
}
