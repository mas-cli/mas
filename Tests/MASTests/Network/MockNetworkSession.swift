//
// MockNetworkSession.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

internal import Foundation
@testable private import mas

/// Mock NetworkSession for testing with a saved response payload file.
struct MockNetworkSession: NetworkSession {
	private let dataResponse: (Data, URLResponse)

	/// Initializes a mock URL session with a resource for the response.
	///
	/// - Parameter responseResource: Resource containing response body.
	/// - Throws: An `Error` if any problem occurs.
	init(responseResource: String) throws {
		dataResponse = (try Data(fromResource: responseResource), URLResponse())
	}

	func data(from _: URL) -> (Data, URLResponse) {
		dataResponse
	}
}
