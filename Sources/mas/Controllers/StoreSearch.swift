//
//  StoreSearch.swift
//  mas
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit

/// Protocol for searching the MAS catalog.
protocol StoreSearch {
    func lookup(appID: AppID) -> Promise<SearchResult?>
    func search(for appName: String) -> Promise<[SearchResult]>
}

enum Entity: String {
    case desktopSoftware
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
    func searchURL(
        for appName: String,
        inCountry country: String?,
        ofEntity entity: Entity = .desktopSoftware
    ) -> URL? {
        guard var components = URLComponents(string: "https://itunes.apple.com/search") else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "entity", value: entity.rawValue),
        ]

        if let country {
            components.queryItems!.append(URLQueryItem(name: "country", value: country))
        }

        components.queryItems!.append(URLQueryItem(name: "term", value: appName))

        return components.url
    }

    /// Builds the lookup URL for an app.
    ///
    /// - Parameter appID: MAS app identifier.
    /// - Returns: URL for the lookup service or nil if appID can't be encoded.
    func lookupURL(forAppID appID: AppID, inCountry country: String?) -> URL? {
        guard var components = URLComponents(string: "https://itunes.apple.com/lookup") else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "entity", value: "desktopSoftware"),
        ]

        if let country {
            components.queryItems!.append(URLQueryItem(name: "country", value: country))
        }

        components.queryItems!.append(URLQueryItem(name: "id", value: "\(appID)"))

        return components.url
    }
}
