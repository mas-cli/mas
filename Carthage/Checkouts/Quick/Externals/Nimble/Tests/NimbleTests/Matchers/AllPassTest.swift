import XCTest
import Nimble

/// Add operators to `Optional` for conforming `Comparable` that removed in Swift 3.0
extension Optional where Wrapped: Comparable {
    static func < (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?):
            return l < r
        case (nil, _?):
            return true
        default:
            return false
        }
    }

    static func > (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?):
            return l > r
        default:
            return rhs < lhs
        }
    }

    static func <= (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?):
            return l <= r
        default:
            return !(rhs < lhs)
        }
    }

    static func >= (lhs: Optional, rhs: Optional) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?):
            return l >= r
        default:
            return !(lhs < rhs)
        }
    }
}

final class AllPassTest: XCTestCase {
    func testAllPassArray() {
        expect([1, 2, 3, 4]).to(allPass({$0 < 5}))
        expect([1, 2, 3, 4]).toNot(allPass({$0 > 5}))

        failsWithErrorMessage(
            "expected to all pass a condition, but failed first at element <3> in <[1, 2, 3, 4]>") {
                expect([1, 2, 3, 4]).to(allPass({$0 < 3}))
        }
        failsWithErrorMessage("expected to not all pass a condition") {
            expect([1, 2, 3, 4]).toNot(allPass({$0 < 5}))
        }
        failsWithErrorMessage(
            "expected to all be something, but failed first at element <3> in <[1, 2, 3, 4]>") {
                expect([1, 2, 3, 4]).to(allPass("be something", {$0 < 3}))
        }
        failsWithErrorMessage("expected to not all be something") {
            expect([1, 2, 3, 4]).toNot(allPass("be something", {$0 < 5}))
        }
    }

    func testAllPassMatcher() {
        expect([1, 2, 3, 4]).to(allPass(beLessThan(5)))
        expect([1, 2, 3, 4]).toNot(allPass(beGreaterThan(5)))

        failsWithErrorMessage(
            "expected to all be less than <3>, but failed first at element <3> in <[1, 2, 3, 4]>") {
                expect([1, 2, 3, 4]).to(allPass(beLessThan(3)))
        }
        failsWithErrorMessage("expected to not all be less than <5>") {
            expect([1, 2, 3, 4]).toNot(allPass(beLessThan(5)))
        }
    }

    func testAllPassCollectionsWithOptionalsDontWork() {
        failsWithErrorMessage("expected to all be nil, but failed first at element <nil> in <[nil, nil, nil]>") {
            expect([nil, nil, nil] as [Int?]).to(allPass(beNil()))
        }
        failsWithErrorMessage("expected to all pass a condition, but failed first at element <nil> in <[nil, nil, nil]>") {
            expect([nil, nil, nil] as [Int?]).to(allPass({$0 == nil}))
        }
    }

    func testAllPassCollectionsWithOptionalsUnwrappingOneOptionalLayer() {
        expect([nil, nil, nil] as [Int?]).to(allPass({$0! == nil}))
        expect([nil, 1, nil] as [Int?]).toNot(allPass({$0! == nil}))
        expect([1, 1, 1] as [Int?]).to(allPass({$0! == 1}))
        expect([1, 1, nil] as [Int?]).toNot(allPass({$0! == 1}))
        expect([1, 2, 3] as [Int?]).to(allPass({$0! < 4}))
        expect([1, 2, 3] as [Int?]).toNot(allPass({$0! < 3}))
        expect([1, 2, nil] as [Int?]).to(allPass({$0! < 3}))
    }

    func testAllPassSet() {
        expect(Set([1, 2, 3, 4])).to(allPass({$0 < 5}))
        expect(Set([1, 2, 3, 4])).toNot(allPass({$0 > 5}))

        failsWithErrorMessage("expected to not all pass a condition") {
            expect(Set([1, 2, 3, 4])).toNot(allPass({$0 < 5}))
        }
        failsWithErrorMessage("expected to not all be something") {
            expect(Set([1, 2, 3, 4])).toNot(allPass("be something", {$0 < 5}))
        }
    }

    func testAllPassWithNilAsExpectedValue() {
        failsWithErrorMessageForNil("expected to all pass") {
            expect(nil as [Int]?).to(allPass(beLessThan(5)))
        }
    }
}
