//
//  MasStoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation

/// Manages searching the MAS catalog through the iTunes Search and Lookup APIs.
public class MasStoreSearch: StoreSearch {
    private let networkManager: NetworkManager

    /// Designated initializer.
    public init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    /// Searches for an app.
    ///
    /// - Parameter appName: MAS ID of app
    /// - Returns: Search results list of app. List will have no records if there were no matches. Never nil.
    /// - Throws: Error if there is a problem with the network request.
    public func search(for appName: String) throws -> SearchResultList {
        guard let url = searchURL(for: appName)
        else { throw MASError.urlEncoding }

        return try loadSearchResults(url)
    }

    /// Looks up app details.
    ///
    /// - Parameter appId: MAS ID of app
    /// - Returns: Search result record of app or nil if no apps match the ID.
    /// - Throws: Error if there is a problem with the network request.
    public func lookup(app appId: Int) throws -> SearchResult? {
        guard let url = lookupURL(forApp: appId)
        else { throw MASError.urlEncoding }

        let results = try loadSearchResults(url)
        guard let searchResult = results.results.first
        else { return nil }

        return searchResult
    }

    private func loadSearchResults(_ url: URL) throws -> SearchResultList {
        let data = try networkManager.loadDataSync(from: url)
        do {
            return try JSONDecoder().decode(SearchResultList.self, from: data)
        } catch {
            throw MASError.jsonParsing(error: error as NSError)
        }
    }
}
