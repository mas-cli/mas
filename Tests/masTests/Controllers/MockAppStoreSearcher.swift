//
//  MockAppStoreSearcher.swift
//  masTests
//
//  Created by Ben Chatelain on 1/4/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import PromiseKit

@testable import mas

class MockAppStoreSearcher: AppStoreSearcher {
    var apps: [AppID: SearchResult] = [:]

    func search(for searchTerm: String) -> Promise<[SearchResult]> {
        .value(apps.filter { $1.trackName.contains(searchTerm) }.map { $1 })
    }

    func lookup(appID: AppID) -> Promise<SearchResult> {
        guard let result = apps[appID] else {
            return Promise(error: MASError.unknownAppID(appID))
        }

        return .value(result)
    }

    func reset() {
        apps = [:]
    }
}
