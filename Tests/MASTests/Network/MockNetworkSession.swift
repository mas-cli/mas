//
// MockNetworkSession.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

internal import Foundation
@testable private import MAS

/// Mock NetworkSession for testing with a saved response payload file.
struct MockNetworkSession: NetworkSession {
	private let data: (Data, URLResponse)

	/// Initializes a mock URL session with a resource for the response.
	///
	/// - Parameter responseResource: Resource containing response body.
	init(responseResource: String) throws {
		data = (try Data(fromResource: responseResource), URLResponse())
	}

	func data(from _: URL) -> (Data, URLResponse) {
		data
	}
}
