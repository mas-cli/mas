//
//  StoreSearchMock.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/4/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import PromiseKit

@testable import MasKit

class StoreSearchMock: StoreSearch {
    var apps: [UInt64: SearchResult] = [:]

    func search(for appName: String) -> Promise<[SearchResult]> {
        let filtered = apps.filter { $1.trackName.contains(appName) }
        let results = filtered.map { $1 }
        return .value(results)
    }

    func lookup(app appId: UInt64) -> Promise<SearchResult?> {
        guard let result = apps[appId]
        else {
            return Promise(error: MASError.noSearchResultsFound)
        }

        return .value(result)
    }

    func reset() {
        apps = [:]
    }
}
