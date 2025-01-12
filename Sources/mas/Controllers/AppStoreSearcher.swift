//
//  AppStoreSearcher.swift
//  mas
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import PromiseKit

/// Protocol for searching the MAS catalog.
protocol AppStoreSearcher {
    /// Looks up app details.
    ///
    /// - Parameters:
    ///   - appID: App ID.
    ///   - region: The `ISORegion` of the storefront in which to lookup apps.
    /// - Returns: A `Promise` for the `SearchResult` for the given `appID` if `appID` is valid.
    ///   A `Promise` for `MASError.unknownAppID(appID)` if `appID` is invalid.
    ///   A `Promise` for some other `Error` if any problems occur.
    func lookup(appID: AppID, inRegion region: ISORegion?) -> Promise<SearchResult>

    /// Searches for apps.
    ///
    /// - Parameters:
    ///   - searchTerm: Term for which to search.
    ///   - region: The `ISORegion` of the storefront in which to search for apps.
    /// - Returns: A `Promise` for an `Array` of `SearchResult`s matching `searchTerm`.
    func search(for searchTerm: String, inRegion region: ISORegion?) -> Promise<[SearchResult]>
}

extension AppStoreSearcher {
    /// Looks up app details.
    ///
    /// - Parameter appID: App ID.
    /// - Returns: A `Promise` for the `SearchResult` for the given `appID` if `appID` is valid.
    ///   A `Promise` for `MASError.unknownAppID(appID)` if `appID` is invalid.
    ///   A `Promise` for some other `Error` if any problems occur.
    func lookup(appID: AppID) -> Promise<SearchResult> {
        lookup(appID: appID, inRegion: Storefront.isoRegion)
    }

    /// Searches for apps.
    ///
    /// - Parameter searchTerm: Term for which to search.
    /// - Returns: A `Promise` for an `Array` of `SearchResult`s matching `searchTerm`.
    func search(for searchTerm: String) -> Promise<[SearchResult]> {
        search(for: searchTerm, inRegion: Storefront.isoRegion)
    }
}
