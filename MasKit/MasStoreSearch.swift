//
//  MasStoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Manages searching the MAS catalog through the iTunes Search and Lookup APIs.
public class MasStoreSearch: StoreSearch {
    private let networkManager: NetworkManager

    /// Designated initializer.
    public init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    /// Looks up app details.
    ///
    /// - Parameter appId: MAS ID of app
    /// - Returns: Search result record of app or nil if no apps match the ID.
    /// - Throws: Error if there is a problem with the network request.
    public func lookup(app appId: String) throws -> SearchResult? {
        guard let url = lookupURL(forApp: appId)
            else { throw MASError.searchFailed }

        let result = networkManager.loadDataSync(from: url)

        // Unwrap network result
        guard case let .success(data) = result
            else {
                if case let .failure(error) = result {
                    throw error
                }
                throw MASError.searchFailed
        }

        guard let results = try? JSONDecoder().decode(SearchResultList.self, from: data)
            else {
                // parse error
                throw MASError.searchFailed
        }

        guard let searchResult = results.results.first
            else { return nil }

        return searchResult
    }
}
