import Foundation

// Ideally we would always use `StaticString` as the type for tracking the file name
// that expectations originate from, for consistency with `assert` etc. from the
// stdlib, and because recent versions of the XCTest overlay require `StaticString`
// when calling `XCTFail`. Under the Objective-C runtime (i.e. building on Mac), we
// have to use `String` instead because StaticString can't be generated from Objective-C
#if SWIFT_PACKAGE
public typealias FileString = StaticString
#else
public typealias FileString = String
#endif

public final class SourceLocation: NSObject {
    public let file: FileString
    public let line: UInt

    override init() {
        file = "Unknown File"
        line = 0
    }

    init(file: FileString, line: UInt) {
        self.file = file
        self.line = line
    }

    override public var description: String {
        return "\(file):\(line)"
    }
}
