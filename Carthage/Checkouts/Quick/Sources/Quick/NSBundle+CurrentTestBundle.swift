#if canImport(Darwin)

import Foundation

extension Bundle {

    /**
     Locates the first bundle with a '.xctest' file extension.
     */
    internal static var currentTestBundle: Bundle? {
        return allBundles.first { $0.bundlePath.hasSuffix(".xctest") }
    }

    /**
     Return the module name of the bundle.
     Uses the bundle filename and transform it to match Xcode's transformation.
     Module name has to be a valid "C99 extended identifier".
     */
    internal var moduleName: String {
        let fileName = bundleURL.fileName
        return fileName.c99ExtendedIdentifier
    }
}

#endif
