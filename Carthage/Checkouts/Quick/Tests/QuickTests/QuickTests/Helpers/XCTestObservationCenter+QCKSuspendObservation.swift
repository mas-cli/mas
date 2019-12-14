import Foundation
import XCTest

/// This allows us to only suspend observation for observers by provided by Apple
/// as a part of the XCTest framework. In particular it is important that we not
/// suspend the observer added by Nimble, otherwise it is unable to properly
/// report assertion failures.
private func isFromApple(observer: XCTestObservation) -> Bool {
    #if canImport(Darwin)
    guard let bundleIdentifier = Bundle(for: type(of: observer)).bundleIdentifier else {
        return false
    }
    return bundleIdentifier.contains("com.apple.dt.XCTest")
    #else
    // https://github.com/apple/swift-corelibs-xctest/blob/swift-5.0.1-RELEASE/Sources/XCTest/Public/XCTestMain.swift#L91-L93
    return String(describing: observer) == "XCTest.PrintObserver"
        || String(describing: type(of: observer)) == "PrintObserver"
    #endif
}

/**
 Add the ability to temporarily disable internal XCTest execution observation in
 order to run isolated XCTestSuite instances while the QuickTests test suite is running.
 */
extension XCTestObservationCenter {
    /**
     Suspends test suite observation for XCTest-provided observers for the duration that
     the block is executing. Any test suites that are executed within the block do not
     generate any log output. Failures are still reported.

     Use this method to run XCTestSuite objects while another XCTestSuite is running.
     Without this method, tests fail with the message: "Timed out waiting for IDE
     barrier message to complete" or "Unexpected TestSuiteDidStart".
     */
    func qck_suspendObservation<T>(forBlock block: () -> T) -> T {
        #if canImport(Darwin)
        let originalObservers = value(forKey: "observers") as? [XCTestObservation] ?? []
        #else
        let originalObservers: [XCTestObservation] = {
            // https://github.com/apple/swift-corelibs-xctest/blob/swift-5.0.1-RELEASE/Sources/XCTest/Public/XCTestObservationCenter.swift#L20-L22
            let mirror = Mirror(reflecting: self)
            let observers = mirror.descendant("observers") as? Set<AnyHashable> ?? []
            return observers.compactMap { hashable in
                // https://github.com/apple/swift-corelibs-xctest/blob/swift-5.0.1-RELEASE/Sources/XCTest/Private/ObjectWrapper.swift#L16-L17
                let wrapperMirror = Mirror(reflecting: hashable.base)
                return wrapperMirror.descendant("object") as? XCTestObservation
            }
        }()
        #endif
        var suspendedObservers = [XCTestObservation]()

        for observer in originalObservers where isFromApple(observer: observer) {
            suspendedObservers.append(observer)
            removeTestObserver(observer)
        }
        defer {
            for observer in suspendedObservers {
                addTestObserver(observer)
            }
        }

        return block()
    }
}
