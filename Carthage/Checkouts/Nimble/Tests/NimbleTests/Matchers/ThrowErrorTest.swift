import XCTest
import Nimble

enum NimbleError: Error {
    case laugh
    case cry
}

enum EquatableError: Error, Equatable {
    case parameterized(x: Int)
}

extension EquatableError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .parameterized(let x):
            return "parameterized(x: \(x))"
        }
    }
}

enum CustomDebugStringConvertibleError: Error {
    // swiftlint:disable identifier_name
    case a
    case b
    // swiftlint:enable identifier_name
}

extension CustomDebugStringConvertibleError: CustomDebugStringConvertible {
    var debugDescription: String {
        return "code=\(_code)"
    }
}

final class ThrowErrorTest: XCTestCase {
    func testPositiveMatches() {
        expect { throw NimbleError.laugh }.to(throwError())
        expect { throw NimbleError.laugh }.to(throwError(NimbleError.laugh))
        expect { throw NimbleError.laugh }.to(throwError(errorType: NimbleError.self))
        expect { throw EquatableError.parameterized(x: 1) }.to(throwError(EquatableError.parameterized(x: 1)))
        expect { throw EquatableError.parameterized(x: 1) }.toNot(throwError(EquatableError.parameterized(x: 2)))
    }

    func testPositiveMatchesWithClosures() {
        // Generic typed closure
        expect { throw EquatableError.parameterized(x: 42) }.to(throwError { error in
            guard case EquatableError.parameterized(let x) = error else { fail(); return }
            expect(x) >= 1
        })
        // Explicit typed closure
        expect { throw EquatableError.parameterized(x: 42) }.to(throwError { (error: EquatableError) in
            guard case .parameterized(let x) = error else { fail(); return }
            expect(x) >= 1
        })
        // Typed closure over errorType argument
        expect { throw EquatableError.parameterized(x: 42) }.to(throwError(errorType: EquatableError.self) { error in
            guard case .parameterized(let x) = error else { fail(); return }
            expect(x) >= 1
        })
        // Typed closure over error argument
        expect { throw NimbleError.laugh }.to(throwError(NimbleError.laugh) { (error: Error) in
            expect(error._domain).to(beginWith("Nim"))
        })
        // Typed closure over error argument
        expect { throw NimbleError.laugh }.to(throwError(NimbleError.laugh) { (error: Error) in
            expect(error._domain).toNot(beginWith("as"))
        })
    }

    func testNegativeMatches() {
        // Same case, different arguments
        failsWithErrorMessage("expected to throw error <parameterized(x: 2)>, got <parameterized(x: 1)>") {
            expect { throw EquatableError.parameterized(x: 1) }.to(throwError(EquatableError.parameterized(x: 2)))
        }
        // Same case, different arguments
        failsWithErrorMessage("expected to throw error <parameterized(x: 2)>, got <parameterized(x: 1)>") {
            expect { throw EquatableError.parameterized(x: 1) }.to(throwError(EquatableError.parameterized(x: 2)))
        }
        // Different case
        failsWithErrorMessage("expected to throw error <cry>, got <laugh>") {
            expect { throw NimbleError.laugh }.to(throwError(NimbleError.cry))
        }
        // Different case with closure
        failsWithErrorMessage("expected to throw error <cry> that satisfies block, got <laugh>") {
            expect { throw NimbleError.laugh }.to(throwError(NimbleError.cry) { _ in return })
        }
        // Different case, implementing CustomDebugStringConvertible
        failsWithErrorMessage("expected to throw error <code=1>, got <code=0>") {
            expect { throw CustomDebugStringConvertibleError.a }.to(throwError(CustomDebugStringConvertibleError.b))
        }
    }

    func testPositiveNegatedMatches() {
        // No error at all
        expect { return }.toNot(throwError())
        // Different case
        expect { throw NimbleError.laugh }.toNot(throwError(NimbleError.cry))
    }

    func testNegativeNegatedMatches() {
        // No error at all
        failsWithErrorMessage("expected to not throw any error, got <laugh>") {
            expect { throw NimbleError.laugh }.toNot(throwError())
        }
        // Different error
        failsWithErrorMessage("expected to not throw error <laugh>, got <laugh>") {
            expect { throw NimbleError.laugh }.toNot(throwError(NimbleError.laugh))
        }
    }

    func testNegativeMatchesDoNotCallClosureWithoutError() {
        failsWithErrorMessage("expected to throw error that satisfies block, got no error") {
            expect { return }.to(throwError { _ in
                fail()
            })
        }

        failsWithErrorMessage("expected to throw error <laugh> that satisfies block, got no error") {
            expect { return }.to(throwError(NimbleError.laugh) { _ in
                fail()
            })
        }
    }

    func testNegativeMatchesWithClosure() {
        let moduleName = "NimbleTests"
        let innerFailureMessage = "expected to equal <foo>, got <\(moduleName).NimbleError>"
        let closure = { (error: Error) -> Void in
            expect(error._domain).to(equal("foo"))
        }

        failsWithErrorMessage([innerFailureMessage, "expected to throw error that satisfies block, got <laugh>"]) {
            expect { throw NimbleError.laugh }.to(throwError(closure: closure))
        }

        failsWithErrorMessage([innerFailureMessage, "expected to throw error from type <NimbleError> that satisfies block, got <laugh>"]) {
            expect { throw NimbleError.laugh }.to(throwError(errorType: NimbleError.self, closure: closure))
        }

        failsWithErrorMessage([innerFailureMessage, "expected to throw error <laugh> that satisfies block, got <laugh>"]) {
            expect { throw NimbleError.laugh }.to(throwError(NimbleError.laugh, closure: closure))
        }
    }

    func testNonVoidClosure() {
        expect { return 1 }.toNot(throwError())
        expect { return 2 }.toNot(throwError(NimbleError.laugh))
        expect { return 3 }.toNot(throwError(errorType: NimbleError.self))
        expect { return 4 }.toNot(throwError(EquatableError.parameterized(x: 1)))
        expect { return 5 }.toNot(throwError(EquatableError.parameterized(x: 2)))

        // swiftlint:disable unused_closure_parameter

        // Generic typed closure
        expect { return "1" }.toNot(throwError { error in })
        // Explicit typed closure
        expect { return "2" }.toNot(throwError { (error: EquatableError) in })
        // Typed closure over errorType argument
        expect { return "3" }.toNot(throwError(errorType: EquatableError.self) { error in })
        // Typed closure over error argument
        expect { return "4" }.toNot(throwError(NimbleError.laugh) { (error: Error) in })
        // Typed closure over error argument
        expect { return "5" }.toNot(throwError(NimbleError.laugh) { (error: Error) in })

        // swiftlint:enable unused_closure_parameter
    }

    func testChainOnThrowError() {
        expect { () throws -> Int in return 5 }.toNot(throwError()).to(equal(5))
    }
}
