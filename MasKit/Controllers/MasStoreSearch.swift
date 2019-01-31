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

    /// Searches for an app.
    ///
    /// - Parameter appName: MAS ID of app
    /// - Returns: Search results list of app. List will have no records if there were no matches. Never nil.
    /// - Throws: Error if there is a problem with the network request.
    public func search(for appName: String) throws -> SearchResultList {
        guard let url = searchURL(for: appName)
        else { throw MASError.urlEncoding }

        let result = networkManager.loadDataSync(from: url)

        // Unwrap network result
        guard case let .success(data) = result
        else {
            if case let .failure(error) = result {
                throw error
            }
            throw MASError.noData
        }

        do {
            let results = try JSONDecoder().decode(SearchResultList.self, from: data)
            return results
        } catch {
            throw MASError.jsonParsing(error: error as NSError)
        }
    }

    /// Looks up app details.
    ///
    /// - Parameter appId: MAS ID of app
    /// - Returns: Search result record of app or nil if no apps match the ID.
    /// - Throws: Error if there is a problem with the network request.
    public func lookup(app appId: Int) throws -> SearchResult? {
        guard let url = lookupURL(forApp: appId)
        else { throw MASError.urlEncoding }

        let result = networkManager.loadDataSync(from: url)

        // Unwrap network result
        guard case let .success(data) = result
        else {
            if case let .failure(error) = result {
                throw error
            }
            throw MASError.noData
        }

        do {
            let results = try JSONDecoder().decode(SearchResultList.self, from: data)

            guard let searchResult = results.results.first
            else { return nil }

            return searchResult
        } catch {
            throw MASError.jsonParsing(error: error as NSError)
        }
    }
}
