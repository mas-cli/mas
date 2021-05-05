//
//  StoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation

/// Protocol for searching the MAS catalog.
protocol StoreSearch {
    func lookup(app appId: Int, _ completion: @escaping (SearchResult?, Error?) -> Void)
    func search(for appName: String, _ completion: @escaping ([SearchResult]?, Error?) -> Void)
}

// MARK: - Common methods
extension StoreSearch {
    /// Looks up app details.
    ///
    /// - Parameter appId: MAS ID of app
    /// - Returns: Search result record of app or nil if no apps match the ID.
    /// - Throws: Error if there is a problem with the network request.
    func lookup(app appId: Int) throws -> SearchResult? {
        var result: SearchResult?
        var error: Error?

        let group = DispatchGroup()
        group.enter()
        lookup(app: appId) {
            result = $0
            error = $1
            group.leave()
        }

        group.wait()

        if let error = error {
            throw error
        }

        return result
    }

    /// Searches for an app.
    ///
    /// - Parameter appName: MAS ID of app
    /// - Returns: Search results. Empty if there were no matches.
    /// - Throws: Error if there is a problem with the network request.
    func search(for appName: String) throws -> [SearchResult] {
        var results: [SearchResult]?
        var error: Error?

        let group = DispatchGroup()
        group.enter()
        search(for: appName) {
            results = $0
            error = $1
            group.leave()
        }

        group.wait()

        if let error = error {
            throw error
        }

        return results!
    }

    /// Builds the search URL for an app.
    ///
    /// - Parameter appName: MAS app identifier.
    /// - Returns: URL for the search service or nil if appName can't be encoded.
    func searchURL(for appName: String) -> URL? {
        guard var components = URLComponents(string: "https://itunes.apple.com/search") else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "entity", value: "macSoftware"),
            URLQueryItem(name: "term", value: appName),
        ]
        return components.url
    }

    /// Builds the lookup URL for an app.
    ///
    /// - Parameter appId: MAS app identifier.
    /// - Returns: URL for the lookup service or nil if appId can't be encoded.
    func lookupURL(forApp appId: Int) -> URL? {
        guard var components = URLComponents(string: "https://itunes.apple.com/lookup") else {
            return nil
        }

        components.queryItems = [URLQueryItem(name: "id", value: "\(appId)")]
        return components.url
    }
}
