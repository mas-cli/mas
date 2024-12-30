//
//  MockAppStoreSearcher.swift
//  masTests
//
//  Created by Ben Chatelain on 1/4/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import PromiseKit

@testable import mas

struct MockAppStoreSearcher: AppStoreSearcher {
    let apps: [AppID: SearchResult]

    init(_ apps: [AppID: SearchResult] = [:]) {
        self.apps = apps
    }

    func lookup(appID: AppID, inRegion _: ISORegion?) -> Promise<SearchResult> {
        guard let result = apps[appID] else {
            return Promise(error: MASError.unknownAppID(appID))
        }

        return .value(result)
    }

    func search(for searchTerm: String, inRegion _: ISORegion?) -> Promise<[SearchResult]> {
        .value(apps.filter { $1.trackName.contains(searchTerm) }.map { $1 })
    }
}
