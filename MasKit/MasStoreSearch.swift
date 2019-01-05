//
//  MasStoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Manages searching the MAS catalog through the iTunes Search and Lookup APIs.
public class MasStoreSearch: StoreSearch {
    private let urlSession: URLSession

    /// Designated initializer.
    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    /// Looks up app details.
    ///
    /// - Parameter appId: MAS ID of app
    /// - Returns: Search result record of app or nil if no apps match the ID.
    /// - Throws: Error if there is a problem with the network request.
    public func lookup(app appId: String) throws -> SearchResult? {
        guard let lookupURLString = lookupURLString(forApp: appId),
            let jsonData = urlSession.requestSynchronousDataWithURLString(lookupURLString)
            else {
                // network error
                throw MASError.searchFailed
        }

        guard let results = try? JSONDecoder().decode(SearchResultList.self, from: jsonData)
            else {
                // parse error
                throw MASError.searchFailed
        }

        guard let result = results.results.first
            else { return nil }

        return result
    }
}
