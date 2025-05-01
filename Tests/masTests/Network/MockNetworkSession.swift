//
//  MockNetworkSession.swift
//  masTests
//
//  Created by Ben Chatelain on 2019-01-05.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

@testable import mas

/// Mock NetworkSession for testing with a saved response payload file.
struct MockNetworkSession: NetworkSession {
	private let data: (Data, URLResponse)

	/// Initializes a mock URL session with a resource for the response.
	///
	/// - Parameter responseResource: Resource containing response body.
	init(responseResource: String) {
		data = (Data(from: responseResource), URLResponse())
	}

	func data(from _: URL) -> (Data, URLResponse) {
		data
	}
}
