//
//  AppStoreSearcher.swift
//  mas
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Protocol for searching the MAS catalog.
protocol AppStoreSearcher {
    /// Looks up app details.
    ///
    /// - Parameters:
    ///   - appID: App ID.
    ///   - region: The `ISORegion` of the storefront in which to lookup apps.
    /// - Returns: The `SearchResult` for the given `appID` if `appID` is valid.
    /// - Throws: A `MASError.unknownAppID(appID)` if `appID` is invalid.
    ///   Some other `Error` if any problems occur.
    func lookup(appID: AppID, inRegion region: ISORegion?) async throws -> SearchResult

    /// Searches for apps.
    ///
    /// - Parameters:
    ///   - searchTerm: Term for which to search.
    ///   - region: The `ISORegion` of the storefront in which to search for apps.
    /// - Returns: An `Array` of `SearchResult`s matching `searchTerm`.
    /// - Throws: An `Error` if any problems occur.
    func search(for searchTerm: String, inRegion region: ISORegion?) async throws -> [SearchResult]
}

extension AppStoreSearcher {
    /// Looks up app details.
    ///
    /// - Parameter appID: App ID.
    /// - Returns: The `SearchResult` for the given `appID` if `appID` is valid.
    /// - Throws: A `MASError.unknownAppID(appID)` if `appID` is invalid.
    ///   Some other `Error` if any problems occur.
    func lookup(appID: AppID) async throws -> SearchResult {
        try await lookup(appID: appID, inRegion: Storefront.isoRegion)
    }

    /// Searches for apps.
    ///
    /// - Parameter searchTerm: Term for which to search.
    /// - Returns: An `Array` of `SearchResult`s matching `searchTerm`.
    /// - Throws: An `Error` if any problems occur.
    func search(for searchTerm: String) async throws -> [SearchResult] {
        try await search(for: searchTerm, inRegion: Storefront.isoRegion)
    }
}
