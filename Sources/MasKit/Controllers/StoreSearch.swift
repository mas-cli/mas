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

        if let country = country {
            components.queryItems!.append(country)
        }

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

        components.queryItems = [
            URLQueryItem(name: "id", value: "\(appId)"),
            URLQueryItem(name: "entity", value: "desktopSoftware"),
        ]

        if let country = country {
            components.queryItems!.append(country)
        }

        return components.url
    }

    private var country: URLQueryItem? {
        // CommerceKit and StoreFoundation don't seem to expose the region of the Apple ID signed
        // into the App Store. Instead, we'll make an educated guess that it matches the currently
        // selected locale in macOS. This obviously isn't always going to match, but it's probably
        // better than passing no "country" at all to the iTunes Search API.
        // https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
        guard let region = Locale.autoupdatingCurrent.regionCode else {
            return nil
        }

        return URLQueryItem(name: "country", value: region)
    }
}
