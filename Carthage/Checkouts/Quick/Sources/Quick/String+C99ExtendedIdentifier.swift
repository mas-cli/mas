#if canImport(Darwin)
import Foundation

extension String {
    private static var invalidCharacters: CharacterSet = {
        var invalidCharacters = CharacterSet()

        let invalidCharacterSets: [CharacterSet] = [
            .whitespacesAndNewlines,
            .illegalCharacters,
            .controlCharacters,
            .punctuationCharacters,
            .nonBaseCharacters,
            .symbols,
        ]

        for invalidSet in invalidCharacterSets {
            invalidCharacters.formUnion(invalidSet)
        }

        return invalidCharacters
    }()

    internal var c99ExtendedIdentifier: String {
        let validComponents = components(separatedBy: String.invalidCharacters)
        let result = validComponents.joined(separator: "_")

        return result.isEmpty ? "_" : result
    }
}

/// Extension methods or properties for NSObject subclasses are invisible from
/// the Objective-C runtime on static linking unless the consumers add `-ObjC`
/// linker flag, so let's make a wrapper class to mitigate that situation.
///
/// See: https://github.com/Quick/Quick/issues/785 and https://github.com/Quick/Quick/pull/803
@objc
class QCKObjCStringUtils: NSObject {
    override private init() {}

    @objc
    static func c99ExtendedIdentifier(from string: String) -> String {
        return string.c99ExtendedIdentifier
    }
}
#endif
