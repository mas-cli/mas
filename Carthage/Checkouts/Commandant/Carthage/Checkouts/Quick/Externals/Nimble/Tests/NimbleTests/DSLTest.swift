import XCTest
import Nimble

private func nonThrowingInt() -> Int {
    return 1
}

private func throwingInt() throws -> Int {
    return 1
}

final class DSLTest: XCTestCase {
    func testExpectAutoclosureNonThrowing() throws {
        let _: Expectation<Int> = expect(1)
        let _: Expectation<Int> = expect(nonThrowingInt())
    }

    func testExpectAutoclosureThrowing() throws {
        let _: Expectation<Int> = expect(try throwingInt())
    }

    func testExpectClosure() throws {
        let _: Expectation<Int> = expect { 1 }
        let _: Expectation<Int> = expect { nonThrowingInt() }
        let _: Expectation<Int> = expect { try throwingInt() }
        let _: Expectation<Int> = expect { () -> Int in 1 }
        let _: Expectation<Int> = expect { () -> Int? in 1 }
        let _: Expectation<Int> = expect { () -> Int? in nil }

        let _: Expectation<Void> = expect { }
        let _: Expectation<Void> = expect { () -> Void in }

        let _: Expectation<Void> = expect { return }
        let _: Expectation<Void> = expect { () -> Void in return }

        let _: Expectation<Void> = expect { return () }
        let _: Expectation<Void> = expect { () -> Void in return () }
    }
}
