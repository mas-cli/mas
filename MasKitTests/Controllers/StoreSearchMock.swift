//
//  StoreSearchMock.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/4/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

@testable import MasKit

class StoreSearchMock: StoreSearch {
    var apps: [Int: SearchResult] = [:]

    func search(for appName: String) throws -> SearchResultList {
        let filtered = apps.filter { $1.trackName.contains(appName) }
        return SearchResultList(resultCount: filtered.count, results: filtered.map { $1 })
    }

    func lookup(app appId: Int) throws -> SearchResult? {
        // Negative numbers are invalid
        if appId <= 0 {
            throw MASError.searchFailed
        }

        guard let result = apps[appId]
            else { throw MASError.noSearchResultsFound }

        return result
    }

    func reset() {
        apps = [:]
    }
}
