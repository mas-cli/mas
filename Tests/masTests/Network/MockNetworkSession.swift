//
//  MockNetworkSession.swift
//  masTests
//
//  Created by Ben Chatelain on 2019-01-05.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

@testable import mas

/// Mock NetworkSession for testing with saved JSON response payload files.
struct MockNetworkSession: NetworkSession {
	/// Path to response payload file relative to test bundle.
	private let responseFile: String

	/// Initializes a mock URL session with a file for the response.
	///
	/// - Parameter responseFile: Name of file containing JSON response body.
	init(responseFile: String) {
		self.responseFile = responseFile
	}

	func data(from _: URL) throws -> (Data, URLResponse) {
		(try Data(contentsOf: Bundle.url(for: responseFile), options: .mappedIfSafe), URLResponse())
	}
}
