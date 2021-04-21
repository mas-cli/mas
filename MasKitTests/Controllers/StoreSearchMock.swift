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

    func search(for appName: String, _ completion: @escaping (SearchResultList?, Error?) -> Void) {
        let filtered = apps.filter { $1.trackName.contains(appName) }
        let results = SearchResultList(resultCount: filtered.count, results: filtered.map { $1 })
        completion(results, nil)
    }

    func lookup(app appId: Int, _ completion: @escaping (SearchResult?, Error?) -> Void) {
        // Negative numbers are invalid
        guard appId > 0 else {
            completion(nil, MASError.searchFailed)
            return
        }

        guard let result = apps[appId]
        else {
            completion(nil, MASError.noSearchResultsFound)
            return
        }

        completion(result, nil)
    }

    func reset() {
        apps = [:]
    }
}
