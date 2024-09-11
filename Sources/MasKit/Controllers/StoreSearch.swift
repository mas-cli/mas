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
    func lookup(app appId: UInt64) -> Promise<SearchResult?>
    func search(for appName: String) -> Promise<[SearchResult]>
}

enum Entity: String {
    case macSoftware
    case iPadSoftware
    case iPhoneSoftware = "software"
}

// MARK: - Common methods
extension StoreSearch {
    /// Builds the search URL for an app.
    ///
    /// - Parameter appName: MAS app identifier.
    /// - Returns: URL for the search service or nil if appName can't be encoded.
    func searchURL(for appName: String, inCountry country: String?, ofEntity entity: Entity = .macSoftware) -> URL? {
        guard var components = URLComponents(string: "https://itunes.apple.com/search") else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "entity", value: entity.rawValue),
            URLQueryItem(name: "term", value: appName),
        ]

        if let country {
            components.queryItems!.append(URLQueryItem(name: "country", value: country))
        }

        return components.url
    }

    /// Builds the lookup URL for an app.
    ///
    /// - Parameter appId: MAS app identifier.
    /// - Returns: URL for the lookup service or nil if appId can't be encoded.
    func lookupURL(forApp appId: UInt64, inCountry country: String?) -> URL? {
        guard var components = URLComponents(string: "https://itunes.apple.com/lookup") else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "id", value: "\(appId)"),
            URLQueryItem(name: "entity", value: "desktopSoftware"),
        ]

        if let country {
            components.queryItems!.append(URLQueryItem(name: "country", value: country))
        }

        return components.url
    }
}
