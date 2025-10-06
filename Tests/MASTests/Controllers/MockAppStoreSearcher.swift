//
// MockAppStoreSearcher.swift
// mas
//
// Copyright © 2019 mas-cli. All rights reserved.
//

@testable internal import mas

struct MockAppStoreSearcher: AppStoreSearcher {
	private let resultByAppID: [AppID: SearchResult]

	init(_ resultByAppID: [AppID: SearchResult] = [:]) {
		self.resultByAppID = resultByAppID
	}

	func lookup(appID: AppID, inRegion _: String) throws -> SearchResult {
		guard let result = resultByAppID[appID] else {
			throw MASError.unknownAppID(appID)
		}

		return result
	}

	func search(for searchTerm: String, inRegion _: String) -> [SearchResult] {
		resultByAppID.filter { $1.name.contains(searchTerm) }.map { $1 }
	}
}
