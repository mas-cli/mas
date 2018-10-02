import Foundation
import XCTest
import Result

final class AnyErrorTests: XCTestCase {
	func testAnyError() {
		let error = Error.a
		let anyErrorFromError = AnyError(error)
		let anyErrorFromAnyError = AnyError(anyErrorFromError)
		XCTAssertTrue(anyErrorFromError == anyErrorFromAnyError)
	}
}
