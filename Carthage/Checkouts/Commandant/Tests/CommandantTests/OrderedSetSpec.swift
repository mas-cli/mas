@testable import Commandant
import Foundation
import Quick
import Nimble

class OrderedSetSpec: QuickSpec {
	override func spec() {
		describe("OrderedSet") {
			it("should remove duplicate entries") {
				let input = ["a", "c", "b", "a"]
				let output = OrderedSet(input)
				expect(output.count) == 3
			}

			it("should preserve the order of the given input") {
				let input = ["a", "c", "b", "a"]
				expect(OrderedSet(input).joined()) == "acb"
			}
		}
	}
}
