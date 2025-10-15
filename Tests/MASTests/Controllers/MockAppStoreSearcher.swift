//
// MockAppStoreSearcher.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

@testable internal import mas

struct MockAppStoreSearcher: AppStoreSearcher {
	private let results: [SearchResult]

	init(_ result: SearchResult) {
		self.init([result])
	}

	init(_ results: [SearchResult] = []) {
		self.results = results
	}

	func lookup(appID: AppID, inRegion _: Region) throws -> SearchResult {
		guard let result = results.first else {
			throw MASError.unknownAppID(appID)
		}

		return result
	}

	func search(for _: String, inRegion _: Region) -> [SearchResult] {
		results
	}
}
