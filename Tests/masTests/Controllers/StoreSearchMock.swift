//
//  StoreSearchMock.swift
//  masTests
//
//  Created by Ben Chatelain on 1/4/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import PromiseKit

@testable import mas

class StoreSearchMock: StoreSearch {
    var apps: [AppID: SearchResult] = [:]

    func search(for appName: String) -> Promise<[SearchResult]> {
        let filtered = apps.filter { $1.trackName.contains(appName) }
        let results = filtered.map { $1 }
        return .value(results)
    }

    func lookup(appID: AppID) -> Promise<SearchResult?> {
        guard let result = apps[appID]
        else {
            return Promise(error: MASError.noSearchResultsFound)
        }

        return .value(result)
    }

    func reset() {
        apps = [:]
    }
}
