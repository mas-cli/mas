import Foundation

internal func raiseError(_ message: String) -> Never {
#if canImport(Darwin)
    NSException(name: .internalInconsistencyException, reason: message, userInfo: nil).raise()
#endif

    // This won't be reached when ObjC is available and the exception above is raisd
    fatalError(message)
}
