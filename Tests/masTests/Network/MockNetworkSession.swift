//
// MockNetworkSession.swift
// masTests
//
// Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation
@testable private import mas

/// Mock NetworkSession for testing with a saved response payload file.
struct MockNetworkSession: NetworkSession {
	private let data: (Data, URLResponse)

	/// Initializes a mock URL session with a resource for the response.
	///
	/// - Parameter responseResource: Resource containing response body.
	init(responseResource: String) {
		data = (Data(fromResource: responseResource), URLResponse())
	}

	func data(from _: URL) -> (Data, URLResponse) {
		data
	}
}
