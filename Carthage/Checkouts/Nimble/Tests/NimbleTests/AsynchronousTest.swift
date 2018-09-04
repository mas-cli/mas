import Dispatch
import Foundation
import XCTest
import Nimble

final class AsyncTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (AsyncTest) -> () throws -> Void)] {
        return [
            ("testToEventuallyPositiveMatches", testToEventuallyPositiveMatches),
            ("testToEventuallyNegativeMatches", testToEventuallyNegativeMatches),
            ("testWaitUntilWithCustomDefaultsTimeout", testWaitUntilWithCustomDefaultsTimeout),
            ("testWaitUntilPositiveMatches", testWaitUntilPositiveMatches),
            ("testToEventuallyWithCustomDefaultTimeout", testToEventuallyWithCustomDefaultTimeout),
            ("testWaitUntilTimesOutIfNotCalled", testWaitUntilTimesOutIfNotCalled),
            ("testWaitUntilTimesOutWhenExceedingItsTime", testWaitUntilTimesOutWhenExceedingItsTime),
            ("testWaitUntilNegativeMatches", testWaitUntilNegativeMatches),
            ("testWaitUntilDetectsStalledMainThreadActivity", testWaitUntilDetectsStalledMainThreadActivity),
            ("testCombiningAsyncWaitUntilAndToEventuallyIsNotAllowed", testCombiningAsyncWaitUntilAndToEventuallyIsNotAllowed),
            ("testWaitUntilErrorsIfDoneIsCalledMultipleTimes", testWaitUntilErrorsIfDoneIsCalledMultipleTimes),
            ("testWaitUntilMustBeInMainThread", testWaitUntilMustBeInMainThread),
            ("testToEventuallyMustBeInMainThread", testToEventuallyMustBeInMainThread),
            ("testSubjectUnderTestIsReleasedFromMemory", testSubjectUnderTestIsReleasedFromMemory),
        ]
    }

    class Error: Swift.Error {}
    let errorToThrow = Error()

    private func doThrowError() throws -> Int {
        throw errorToThrow
    }

    func testToEventuallyPositiveMatches() {
        var value = 0
        deferToMainQueue { value = 1 }
        expect { value }.toEventually(equal(1))

        deferToMainQueue { value = 0 }
        expect { value }.toEventuallyNot(equal(1))
    }

    func testToEventuallyNegativeMatches() {
        let value = 0
        failsWithErrorMessage("expected to eventually not equal <0>, got <0>") {
            expect { value }.toEventuallyNot(equal(0))
        }
        failsWithErrorMessage("expected to eventually equal <1>, got <0>") {
            expect { value }.toEventually(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toEventually(equal(1))
        }
        failsWithErrorMessage("unexpected error thrown: <\(errorToThrow)>") {
            expect { try self.doThrowError() }.toEventuallyNot(equal(0))
        }
    }

    func testToEventuallyWithCustomDefaultTimeout() {
        AsyncDefaults.Timeout = 2
        defer {
            AsyncDefaults.Timeout = 1
        }

        var value = 0

        let sleepThenSetValueTo: (Int) -> Void = { newValue in
            Thread.sleep(forTimeInterval: 1.1)
            value = newValue
        }

        var asyncOperation: () -> Void = { sleepThenSetValueTo(1) }

        if #available(OSX 10.10, *) {
            DispatchQueue.global().async(execute: asyncOperation)
        } else {
            DispatchQueue.global(priority: .default).async(execute: asyncOperation)
        }
        expect { value }.toEventually(equal(1))

        asyncOperation = { sleepThenSetValueTo(0) }

        if #available(OSX 10.10, *) {
            DispatchQueue.global().async(execute: asyncOperation)
        } else {
            DispatchQueue.global(priority: .default).async(execute: asyncOperation)
        }
        expect { value }.toEventuallyNot(equal(1))
    }

    func testWaitUntilWithCustomDefaultsTimeout() {
        AsyncDefaults.Timeout = 5
        defer {
            AsyncDefaults.Timeout = 1
        }
        waitUntil { done in
            Thread.sleep(forTimeInterval: 4.8)
            done()
        }
    }

    func testWaitUntilPositiveMatches() {
        waitUntil { done in
            done()
        }
        waitUntil { done in
            deferToMainQueue {
                done()
            }
        }
    }

    func testWaitUntilTimesOutIfNotCalled() {
        failsWithErrorMessage("Waited more than 1.0 second") {
            waitUntil(timeout: 1) { _ in return }
        }
    }

    func testWaitUntilTimesOutWhenExceedingItsTime() {
        var waiting = true
        failsWithErrorMessage("Waited more than 0.01 seconds") {
            waitUntil(timeout: 0.01) { done in
                let asyncOperation: () -> Void = {
                    Thread.sleep(forTimeInterval: 0.1)
                    done()
                    waiting = false
                }
                if #available(OSX 10.10, *) {
                    DispatchQueue.global().async(execute: asyncOperation)
                } else {
                    DispatchQueue.global(priority: .default).async(execute: asyncOperation)
                }
            }
        }

        // "clear" runloop to ensure this test doesn't poison other tests
        repeat {
            RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        } while(waiting)
    }

    func testWaitUntilNegativeMatches() {
        failsWithErrorMessage("expected to equal <2>, got <1>") {
            waitUntil { done in
                Thread.sleep(forTimeInterval: 0.1)
                expect(1).to(equal(2))
                done()
            }
        }
    }

    func testWaitUntilDetectsStalledMainThreadActivity() {
        let msg = "-waitUntil() timed out but was unable to run the timeout handler because the main thread is unresponsive (0.5 seconds is allow after the wait times out). Conditions that may cause this include processing blocking IO on the main thread, calls to sleep(), deadlocks, and synchronous IPC. Nimble forcefully stopped run loop which may cause future failures in test run."
        failsWithErrorMessage(msg) {
            waitUntil(timeout: 1) { done in
                Thread.sleep(forTimeInterval: 5.0)
                done()
            }
        }
    }

    func testCombiningAsyncWaitUntilAndToEventuallyIsNotAllowed() {
        // Currently we are unable to catch Objective-C exceptions when built by the Swift Package Manager
#if !SWIFT_PACKAGE
        let referenceLine = #line + 9
        var msg = "Unexpected exception raised: Nested async expectations are not allowed "
        msg += "to avoid creating flaky tests."
        msg += "\n\n"
        msg += "The call to\n\t"
        msg += "expect(...).toEventually(...) at \(#file):\(referenceLine + 7)\n"
        msg += "triggered this exception because\n\t"
        msg += "waitUntil(...) at \(#file):\(referenceLine + 1)\n"
        msg += "is currently managing the main run loop."
        failsWithErrorMessage(msg) { // reference line
            waitUntil(timeout: 2.0) { done in
                var protected: Int = 0
                DispatchQueue.main.async {
                    protected = 1
                }

                expect(protected).toEventually(equal(1))
                done()
            }
        }
#endif
    }

    func testWaitUntilErrorsIfDoneIsCalledMultipleTimes() {
        failsWithErrorMessage("waitUntil(..) expects its completion closure to be only called once") {
            waitUntil { done in
                deferToMainQueue {
                    done()
                    done()
                }
            }
        }
    }

    func testWaitUntilMustBeInMainThread() {
#if !SWIFT_PACKAGE
        var executedAsyncBlock: Bool = false
        let asyncOperation: () -> Void = {
            expect {
                waitUntil { done in done() }
            }.to(raiseException(named: "InvalidNimbleAPIUsage"))
            executedAsyncBlock = true
        }
        if #available(OSX 10.10, *) {
            DispatchQueue.global().async(execute: asyncOperation)
        } else {
            DispatchQueue.global(priority: .default).async(execute: asyncOperation)
        }
        expect(executedAsyncBlock).toEventually(beTruthy())
#endif
    }

    func testToEventuallyMustBeInMainThread() {
#if !SWIFT_PACKAGE
        var executedAsyncBlock: Bool = false
        let asyncOperation: () -> Void = {
            expect {
                expect(1).toEventually(equal(2))
            }.to(raiseException(named: "InvalidNimbleAPIUsage"))
            executedAsyncBlock = true
        }
        if #available(OSX 10.10, *) {
            DispatchQueue.global().async(execute: asyncOperation)
        } else {
            DispatchQueue.global(priority: .default).async(execute: asyncOperation)
        }
        expect(executedAsyncBlock).toEventually(beTruthy())
#endif
    }

    final class ClassUnderTest {
        var deinitCalled: (() -> Void)?
        var count = 0
        deinit { deinitCalled?() }
    }

    func testSubjectUnderTestIsReleasedFromMemory() {
        var subject: ClassUnderTest? = ClassUnderTest()

        if let sub = subject {
            expect(sub.count).toEventually(equal(0), timeout: 0.1)
            expect(sub.count).toEventuallyNot(equal(1), timeout: 0.1)
        }

        waitUntil(timeout: 0.5) { done in
            subject?.deinitCalled = {
                done()
            }

            deferToMainQueue { subject = nil }
        }
    }

}
