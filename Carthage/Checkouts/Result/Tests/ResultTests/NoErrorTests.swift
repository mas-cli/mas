import Foundation
import XCTest
import Result

final class NoErrorTests: XCTestCase {
	func testEquatable() {
		let foo = Result<Int, NoError>(1)
		let bar = Result<Int, NoError>(1)
		XCTAssertTrue(foo == bar)
	}
}
