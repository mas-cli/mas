import Foundation

#if !canImport(Darwin)
// swift-corelibs-foundation doesn't provide NSException at all, so provide a dummy
class NSException {}
#endif

// NOTE: This file is not intended to be included in the Xcode project. It
//       is picked up by the Swift Package Manager during its build process.

/// A dummy reimplementation of the `NMBExceptionCapture` class to serve
/// as a stand-in for build and runtime environments that don't support
/// Objective C.
internal class ExceptionCapture {
    let finally: (() -> Void)?

    init(handler: ((NSException) -> Void)?, finally: (() -> Void)?) {
        self.finally = finally
    }

    func tryBlock(_ unsafeBlock: (() -> Void)) {
        // We have no way of handling Objective C exceptions in Swift,
        // so we just go ahead and run the unsafeBlock as-is
        unsafeBlock()

        finally?()
    }
}

/// Compatibility with the actual Objective-C implementation
typealias NMBExceptionCapture = ExceptionCapture
