import XCTest
import Nimble
import Foundation

enum ConvertsToBool: ExpressibleByBooleanLiteral, CustomStringConvertible {
    case trueLike, falseLike

    typealias BooleanLiteralType = Bool

    init(booleanLiteral value: Bool) {
        switch value {
        case true: self = .trueLike
        case false: self = .falseLike
        }
    }

    var boolValue: Bool {
        switch self {
        case .trueLike: return true
        case .falseLike: return false
        }
    }

    var description: String {
        switch self {
        case .trueLike: return "TrueLike"
        case .falseLike: return "FalseLike"
        }
    }
}

final class BeTruthyTest: XCTestCase {
    func testShouldMatchNonNilTypes() {
        expect(true as Bool?).to(beTruthy())

        // Support types conforming to `ExpressibleByBooleanLiteral`
        // Nimble extend following types as conforming to `ExpressibleByBooleanLiteral`
        expect(1 as Int8?).to(beTruthy())
        expect(1 as UInt8?).to(beTruthy())
        expect(1 as Int16?).to(beTruthy())
        expect(1 as UInt16?).to(beTruthy())
        expect(1 as Int32?).to(beTruthy())
        expect(1 as UInt32?).to(beTruthy())
        expect(1 as Int64?).to(beTruthy())
        expect(1 as UInt64?).to(beTruthy())
        expect(1 as Float?).to(beTruthy())
        expect(1 as Double?).to(beTruthy())
        expect(1 as Int?).to(beTruthy())
        expect(1 as UInt?).to(beTruthy())
    }

    func testShouldMatchTrue() {
        expect(true).to(beTruthy())

        failsWithErrorMessage("expected to not be truthy, got <true>") {
            expect(true).toNot(beTruthy())
        }
    }

    func testShouldNotMatchNilTypes() {
        expect(false as Bool?).toNot(beTruthy())

        // Support types conforming to `ExpressibleByBooleanLiteral`
        // Nimble extend following types as conforming to `ExpressibleByBooleanLiteral`
        expect(nil as Bool?).toNot(beTruthy())
        expect(nil as Int8?).toNot(beTruthy())
        expect(nil as UInt8?).toNot(beTruthy())
        expect(nil as Int16?).toNot(beTruthy())
        expect(nil as UInt16?).toNot(beTruthy())
        expect(nil as Int32?).toNot(beTruthy())
        expect(nil as UInt32?).toNot(beTruthy())
        expect(nil as Int64?).toNot(beTruthy())
        expect(nil as UInt64?).toNot(beTruthy())
        expect(nil as Float?).toNot(beTruthy())
        expect(nil as Double?).toNot(beTruthy())
        expect(nil as Int?).toNot(beTruthy())
        expect(nil as UInt?).toNot(beTruthy())
    }

    func testShouldNotMatchFalse() {
        expect(false).toNot(beTruthy())

        failsWithErrorMessage("expected to be truthy, got <false>") {
            expect(false).to(beTruthy())
        }
    }

    func testShouldNotMatchNilBools() {
        expect(nil as Bool?).toNot(beTruthy())

        failsWithErrorMessage("expected to be truthy, got <nil>") {
            expect(nil as Bool?).to(beTruthy())
        }
    }

    func testShouldMatchBoolConvertibleTypesThatConvertToTrue() {
        expect(ConvertsToBool.trueLike).to(beTruthy())

        failsWithErrorMessage("expected to not be truthy, got <TrueLike>") {
            expect(ConvertsToBool.trueLike).toNot(beTruthy())
        }
    }

    func testShouldNotMatchBoolConvertibleTypesThatConvertToFalse() {
        expect(ConvertsToBool.falseLike).toNot(beTruthy())

        failsWithErrorMessage("expected to be truthy, got <FalseLike>") {
            expect(ConvertsToBool.falseLike).to(beTruthy())
        }
    }
}

final class BeTrueTest: XCTestCase {
    func testShouldMatchTrue() {
        expect(true).to(beTrue())

        failsWithErrorMessage("expected to not be true, got <true>") {
            expect(true).toNot(beTrue())
        }
    }

    func testShouldNotMatchFalse() {
        expect(false).toNot(beTrue())

        failsWithErrorMessage("expected to be true, got <false>") {
            expect(false).to(beTrue())
        }
    }

    func testShouldNotMatchNilBools() {
        failsWithErrorMessageForNil("expected to not be true, got <nil>") {
            expect(nil as Bool?).toNot(beTrue())
        }

        failsWithErrorMessageForNil("expected to be true, got <nil>") {
            expect(nil as Bool?).to(beTrue())
        }
    }
}

final class BeFalsyTest: XCTestCase {
    func testShouldMatchNilTypes() {
        expect(false as Bool?).to(beFalsy())

        // Support types conforming to `ExpressibleByBooleanLiteral`
        // Nimble extend following types as conforming to `ExpressibleByBooleanLiteral`
        expect(nil as Bool?).to(beFalsy())
        expect(nil as Int8?).to(beFalsy())
        expect(nil as UInt8?).to(beFalsy())
        expect(nil as Int16?).to(beFalsy())
        expect(nil as UInt16?).to(beFalsy())
        expect(nil as Int32?).to(beFalsy())
        expect(nil as UInt32?).to(beFalsy())
        expect(nil as Int64?).to(beFalsy())
        expect(nil as UInt64?).to(beFalsy())
        expect(nil as Float?).to(beFalsy())
        expect(nil as Double?).to(beFalsy())
        expect(nil as Int?).to(beFalsy())
        expect(nil as UInt?).to(beFalsy())
    }

    func testShouldNotMatchTrue() {
        expect(true).toNot(beFalsy())

        failsWithErrorMessage("expected to be falsy, got <true>") {
            expect(true).to(beFalsy())
        }
    }

    func testShouldNotMatchNonNilTypes() {
        expect(true as Bool?).toNot(beFalsy())

        // Support types conforming to `ExpressibleByBooleanLiteral`
        // Nimble extend following types as conforming to `ExpressibleByBooleanLiteral`
        expect(1 as Int8?).toNot(beFalsy())
        expect(1 as UInt8?).toNot(beFalsy())
        expect(1 as Int16?).toNot(beFalsy())
        expect(1 as UInt16?).toNot(beFalsy())
        expect(1 as Int32?).toNot(beFalsy())
        expect(1 as UInt32?).toNot(beFalsy())
        expect(1 as Int64?).toNot(beFalsy())
        expect(1 as UInt64?).toNot(beFalsy())
        expect(1 as Float?).toNot(beFalsy())
        expect(1 as Double?).toNot(beFalsy())
        expect(1 as Int?).toNot(beFalsy())
        expect(1 as UInt?).toNot(beFalsy())
    }

    func testShouldMatchFalse() {
        expect(false).to(beFalsy())

        failsWithErrorMessage("expected to not be falsy, got <false>") {
            expect(false).toNot(beFalsy())
        }
    }

    func testShouldMatchNilBools() {
        expect(nil as Bool?).to(beFalsy())

        failsWithErrorMessage("expected to not be falsy, got <nil>") {
            expect(nil as Bool?).toNot(beFalsy())
        }
    }
}

final class BeFalseTest: XCTestCase {
    func testShouldNotMatchTrue() {
        expect(true).toNot(beFalse())

        failsWithErrorMessage("expected to be false, got <true>") {
            expect(true).to(beFalse())
        }
    }

    func testShouldMatchFalse() {
        expect(false).to(beFalse())

        failsWithErrorMessage("expected to not be false, got <false>") {
            expect(false).toNot(beFalse())
        }
    }

    func testShouldNotMatchNilBools() {
        failsWithErrorMessageForNil("expected to be false, got <nil>") {
            expect(nil as Bool?).to(beFalse())
        }

        failsWithErrorMessageForNil("expected to not be false, got <nil>") {
            expect(nil as Bool?).toNot(beFalse())
        }
    }
}
