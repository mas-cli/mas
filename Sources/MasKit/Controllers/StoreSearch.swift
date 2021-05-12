//
//  StoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit

/// Protocol for searching the MAS catalog.
protocol StoreSearch {
    func lookup(app appId: Int) -> Promise<SearchResult?>
    func search(for appName: String) -> Promise<[SearchResult]>
}

// MARK: - Common methods
extension StoreSearch {
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
