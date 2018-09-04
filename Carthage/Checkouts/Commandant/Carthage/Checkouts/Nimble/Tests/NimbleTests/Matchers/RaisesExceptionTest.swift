import XCTest
import Nimble

#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && !SWIFT_PACKAGE

final class RaisesExceptionTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (RaisesExceptionTest) -> () throws -> Void)] {
        return [
            ("testPositiveMatches", testPositiveMatches),
            ("testPositiveMatchesWithClosures", testPositiveMatchesWithClosures),
            ("testNegativeMatches", testNegativeMatches),
            ("testNegativeMatchesDoNotCallClosureWithoutException", testNegativeMatchesDoNotCallClosureWithoutException),
            ("testNegativeMatchesWithClosure", testNegativeMatchesWithClosure),
        ]
    }

    var anException = NSException(name: NSExceptionName("laugh"), reason: "Lulz", userInfo: ["key": "value"])

    func testPositiveMatches() {
        expect { self.anException.raise() }.to(raiseException())
        expect { self.anException.raise() }.to(raiseException(named: "laugh"))
        expect { self.anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz"))
        expect { self.anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]))
    }

    func testPositiveMatchesWithClosures() {
        expect { self.anException.raise() }.to(raiseException { (exception: NSException) in
            expect(exception.name).to(equal(NSExceptionName("laugh")))
        })
        expect { self.anException.raise() }.to(raiseException(named: "laugh") { (exception: NSException) in
            expect(exception.name.rawValue).to(beginWith("lau"))
        })
        expect { self.anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz") { (exception: NSException) in
            expect(exception.name.rawValue).to(beginWith("lau"))
        })
        expect { self.anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]) { (exception: NSException) in
            expect(exception.name.rawValue).to(beginWith("lau"))
        })

        expect { self.anException.raise() }.to(raiseException(named: "laugh") { (exception: NSException) in
            expect(exception.name.rawValue).toNot(beginWith("as"))
        })
        expect { self.anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz") { (exception: NSException) in
            expect(exception.name.rawValue).toNot(beginWith("df"))
        })
        expect { self.anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]) { (exception: NSException) in
            expect(exception.name.rawValue).toNot(beginWith("as"))
        })
    }

    func testNegativeMatches() {
        failsWithErrorMessage("expected to raise exception with name <foo>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { self.anException.raise() }.to(raiseException(named: "foo"))
        }

        failsWithErrorMessage("expected to raise exception with name <laugh> with reason <bar>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { self.anException.raise() }.to(raiseException(named: "laugh", reason: "bar"))
        }

        failsWithErrorMessage(
            "expected to raise exception with name <laugh> with reason <Lulz> with userInfo <{k = v;}>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { self.anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["k": "v"]))
        }

        failsWithErrorMessage("expected to raise any exception, got no exception") {
            expect { self.anException }.to(raiseException())
        }
        failsWithErrorMessage("expected to not raise any exception, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { self.anException.raise() }.toNot(raiseException())
        }
        failsWithErrorMessage("expected to raise exception with name <laugh> with reason <Lulz>, got no exception") {
            expect { self.anException }.to(raiseException(named: "laugh", reason: "Lulz"))
        }

        failsWithErrorMessage("expected to raise exception with name <bar> with reason <Lulz>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { self.anException.raise() }.to(raiseException(named: "bar", reason: "Lulz"))
        }
        failsWithErrorMessage("expected to not raise exception with name <laugh>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { self.anException.raise() }.toNot(raiseException(named: "laugh"))
        }
        failsWithErrorMessage("expected to not raise exception with name <laugh> with reason <Lulz>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { self.anException.raise() }.toNot(raiseException(named: "laugh", reason: "Lulz"))
        }

        failsWithErrorMessage("expected to not raise exception with name <laugh> with reason <Lulz> with userInfo <{key = value;}>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { self.anException.raise() }.toNot(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]))
        }
    }

    func testNegativeMatchesDoNotCallClosureWithoutException() {
        failsWithErrorMessage("expected to raise exception that satisfies block, got no exception") {
            expect { self.anException }.to(raiseException { (exception: NSException) in
                expect(exception.name).to(equal(NSExceptionName(rawValue: "foo")))
            })
        }

        failsWithErrorMessage("expected to raise exception with name <foo> that satisfies block, got no exception") {
            expect { self.anException }.to(raiseException(named: "foo") { (exception: NSException) in
                expect(exception.name.rawValue).to(equal("foo"))
            })
        }

        failsWithErrorMessage("expected to raise exception with name <foo> with reason <ha> that satisfies block, got no exception") {
            expect { self.anException }.to(raiseException(named: "foo", reason: "ha") { (exception: NSException) in
                expect(exception.name.rawValue).to(equal("foo"))
            })
        }

        failsWithErrorMessage("expected to raise exception with name <foo> with reason <Lulz> with userInfo <{}> that satisfies block, got no exception") {
            expect { self.anException }.to(raiseException(named: "foo", reason: "Lulz", userInfo: [:]) { (exception: NSException) in
                expect(exception.name.rawValue).to(equal("foo"))
                })
        }

        failsWithErrorMessage("expected to not raise any exception, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { self.anException.raise() }.toNot(raiseException())
        }
    }

    func testNegativeMatchesWithClosure() {
        failsWithErrorMessage("expected to raise exception that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { self.anException.raise() }.to(raiseException { (exception: NSException) in
                expect(exception.name.rawValue).to(equal("foo"))
            })
        }

        let innerFailureMessage = "expected to begin with <fo>, got <laugh>"

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <laugh> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { self.anException.raise() }.to(raiseException(named: "laugh") { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <lol> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { self.anException.raise() }.to(raiseException(named: "lol") { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <laugh> with reason <Lulz> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { self.anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz") { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <lol> with reason <wrong> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { self.anException.raise() }.to(raiseException(named: "lol", reason: "wrong") { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <laugh> with reason <Lulz> with userInfo <{key = value;}> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { self.anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]) { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <lol> with reason <Lulz> with userInfo <{}> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { self.anException.raise() }.to(raiseException(named: "lol", reason: "Lulz", userInfo: [:]) { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }
    }
}
#endif
