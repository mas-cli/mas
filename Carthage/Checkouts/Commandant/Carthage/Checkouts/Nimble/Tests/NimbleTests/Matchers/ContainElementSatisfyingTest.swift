import Foundation
import XCTest
import Nimble

final class ContainElementSatisfyingTest: XCTestCase {
    func testContainElementSatisfying() {
        var orderIndifferentArray = [1, 2, 3]
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 1
        }))
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 2
        }))
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 3
        }))

        orderIndifferentArray = [3, 1, 2]
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 1
        }))
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 2
        }))
        expect(orderIndifferentArray).to(containElementSatisfying({ number in
            return number == 3
        }))
    }

    func testContainElementSatisfyingDefaultErrorMessage() {
        let orderIndifferentArray = [1, 2, 3]
        failsWithErrorMessage("expected to find object in collection that satisfies predicate") {
            expect(orderIndifferentArray).to(containElementSatisfying({ number in
                return number == 4
            }))
        }
    }

    func testContainElementSatisfyingSpecificErrorMessage() {
        let orderIndifferentArray = [1, 2, 3]
        failsWithErrorMessage("expected to find object in collection equal to 4") {
            expect(orderIndifferentArray).to(containElementSatisfying({ number in
                return number == 4
            }, "equal to 4"))
        }
    }

    func testContainElementSatisfyingNegativeCase() {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        expect(orderIndifferentArray).toNot(containElementSatisfying({ string in
            return string == "armadillos"
        }))
    }

    func testContainElementSatisfyingNegativeCaseDefaultErrorMessage() {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        failsWithErrorMessage("expected to not find object in collection that satisfies predicate") {
            expect(orderIndifferentArray).toNot(containElementSatisfying({ string in
                return string == "kittens"
            }))
        }
    }

    func testContainElementSatisfyingNegativeCaseSpecificErrorMessage() {
        let orderIndifferentArray = ["puppies", "kittens", "turtles"]
        failsWithErrorMessage("expected to not find object in collection equal to 'kittens'") {
            expect(orderIndifferentArray).toNot(containElementSatisfying({ string in
                return string == "kittens"
            }, "equal to 'kittens'"))
        }
    }
}
