//
// MockAppStoreSearcher.swift
// masTests
//
// Created by Ben Chatelain on 2019-01-04.
// Copyright © 2019 mas-cli. All rights reserved.
//

@testable internal import mas

struct MockAppStoreSearcher: AppStoreSearcher {
	let apps: [AppID: SearchResult]

	init(_ apps: [AppID: SearchResult] = [:]) {
		self.apps = apps
	}

	func lookup(appID: AppID, inRegion _: ISORegion?) throws -> SearchResult {
		guard let result = apps[appID] else {
			throw MASError.unknownAppID(appID)
		}

		return result
	}

	func search(for searchTerm: String, inRegion _: ISORegion?) -> [SearchResult] {
		apps.filter { $1.trackName.contains(searchTerm) }.map { $1 }
	}
}
