import XCTest
import Nimble

#if canImport(Darwin) && !SWIFT_PACKAGE

let anException = NSException(name: NSExceptionName("laugh"), reason: "Lulz", userInfo: ["key": "value"])

final class RaisesExceptionTest: XCTestCase {
    func testPositiveMatches() {
        expect { anException.raise() }.to(raiseException())
        expect { anException.raise() }.to(raiseException(named: "laugh"))
        expect { anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz"))
        expect { anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]))
    }

    func testPositiveMatchesWithClosures() {
        expect { anException.raise() }.to(raiseException { (exception: NSException) in
            expect(exception.name).to(equal(NSExceptionName("laugh")))
        })
        expect { anException.raise() }.to(raiseException(named: "laugh") { (exception: NSException) in
            expect(exception.name.rawValue).to(beginWith("lau"))
        })
        expect { anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz") { (exception: NSException) in
            expect(exception.name.rawValue).to(beginWith("lau"))
        })
        expect { anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]) { (exception: NSException) in
            expect(exception.name.rawValue).to(beginWith("lau"))
        })

        expect { anException.raise() }.to(raiseException(named: "laugh") { (exception: NSException) in
            expect(exception.name.rawValue).toNot(beginWith("as"))
        })
        expect { anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz") { (exception: NSException) in
            expect(exception.name.rawValue).toNot(beginWith("df"))
        })
        expect { anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]) { (exception: NSException) in
            expect(exception.name.rawValue).toNot(beginWith("as"))
        })
    }

    func testNegativeMatches() {
        failsWithErrorMessage("expected to raise exception with name <foo>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { anException.raise() }.to(raiseException(named: "foo"))
        }

        failsWithErrorMessage("expected to raise exception with name <laugh> with reason <bar>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { anException.raise() }.to(raiseException(named: "laugh", reason: "bar"))
        }

        failsWithErrorMessage(
            "expected to raise exception with name <laugh> with reason <Lulz> with userInfo <{k = v;}>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["k": "v"]))
        }

        failsWithErrorMessage("expected to raise any exception, got no exception") {
            expect {}.to(raiseException())
        }
        failsWithErrorMessage("expected to not raise any exception, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { anException.raise() }.toNot(raiseException())
        }
        failsWithErrorMessage("expected to raise exception with name <laugh> with reason <Lulz>, got no exception") {
            expect {}.to(raiseException(named: "laugh", reason: "Lulz"))
        }

        failsWithErrorMessage("expected to raise exception with name <bar> with reason <Lulz>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { anException.raise() }.to(raiseException(named: "bar", reason: "Lulz"))
        }
        failsWithErrorMessage("expected to not raise exception with name <laugh>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { anException.raise() }.toNot(raiseException(named: "laugh"))
        }
        failsWithErrorMessage("expected to not raise exception with name <laugh> with reason <Lulz>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { anException.raise() }.toNot(raiseException(named: "laugh", reason: "Lulz"))
        }

        failsWithErrorMessage("expected to not raise exception with name <laugh> with reason <Lulz> with userInfo <{key = value;}>, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { anException.raise() }.toNot(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]))
        }
    }

    func testNegativeMatchesDoNotCallClosureWithoutException() {
        failsWithErrorMessage("expected to raise exception that satisfies block, got no exception") {
            expect {}.to(raiseException { (exception: NSException) in
                expect(exception.name).to(equal(NSExceptionName(rawValue: "foo")))
            })
        }

        failsWithErrorMessage("expected to raise exception with name <foo> that satisfies block, got no exception") {
            expect {}.to(raiseException(named: "foo") { (exception: NSException) in
                expect(exception.name.rawValue).to(equal("foo"))
            })
        }

        failsWithErrorMessage("expected to raise exception with name <foo> with reason <ha> that satisfies block, got no exception") {
            expect {}.to(raiseException(named: "foo", reason: "ha") { (exception: NSException) in
                expect(exception.name.rawValue).to(equal("foo"))
            })
        }

        failsWithErrorMessage("expected to raise exception with name <foo> with reason <Lulz> with userInfo <{}> that satisfies block, got no exception") {
            expect {}.to(raiseException(named: "foo", reason: "Lulz", userInfo: [:]) { (exception: NSException) in
                expect(exception.name.rawValue).to(equal("foo"))
                })
        }

        failsWithErrorMessage("expected to not raise any exception, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { anException.raise() }.toNot(raiseException())
        }
    }

    func testNegativeMatchesWithClosure() {
        failsWithErrorMessage("expected to raise exception that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }") {
            expect { anException.raise() }.to(raiseException { (exception: NSException) in
                expect(exception.name.rawValue).to(equal("foo"))
            })
        }

        let innerFailureMessage = "expected to begin with <fo>, got <laugh>"

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <laugh> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { anException.raise() }.to(raiseException(named: "laugh") { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <lol> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { anException.raise() }.to(raiseException(named: "lol") { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <laugh> with reason <Lulz> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz") { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <lol> with reason <wrong> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { anException.raise() }.to(raiseException(named: "lol", reason: "wrong") { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <laugh> with reason <Lulz> with userInfo <{key = value;}> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { anException.raise() }.to(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]) { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }

        failsWithErrorMessage([innerFailureMessage, "expected to raise exception with name <lol> with reason <Lulz> with userInfo <{}> that satisfies block, got NSException { name=NSExceptionName(_rawValue: laugh), reason='Lulz', userInfo=[AnyHashable(\"key\"): \"value\"] }"]) {
            expect { anException.raise() }.to(raiseException(named: "lol", reason: "Lulz", userInfo: [:]) { (exception: NSException) in
                expect(exception.name.rawValue).to(beginWith("fo"))
            })
        }
    }

    func testNSExceptionName() {
        let exception = NSException(name: .genericException, reason: nil, userInfo: nil)
        expect { exception.raise() }.to(raiseException(named: .genericException))
    }

    func testNonVoidClosure() {
        expect { return 1 }.toNot(raiseException())
        expect { return 2 }.toNot(raiseException(named: "laugh"))
        expect { return 3 }.toNot(raiseException(named: "laugh", reason: "Lulz"))
        expect { return 4 }.toNot(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]))
        expect { return 5 }.toNot(raiseException(named: "laugh", reason: "Lulz", userInfo: ["key": "value"]) { _ in })
    }

    func testChainOnRaiseException() {
        expect { () -> Int in return 5 }.toNot(raiseException()).to(equal(5))
    }
}
#endif
