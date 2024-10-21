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

private enum URLAction {
    case lookup
    case search

    var queryItemName: String {
        switch self {
        case .lookup:
            return "id"
        case .search:
            return "term"
        }
    }
}

// MARK: - Common methods
extension StoreSearch {
    /// Builds the search URL for an app.
    ///
    /// - Parameters:
    ///   - searchTerm: term for which to search in MAS.
    ///   - country: 2-letter ISO region code of the MAS in which to search.
    ///   - entity: OS platform of apps for which to search.
    /// - Returns: URL for the search service or nil if searchTerm can't be encoded.
    func searchURL(
        for searchTerm: String,
        inCountry country: String?,
        ofEntity entity: Entity = .desktopSoftware
    ) -> URL? {
        url(.search, searchTerm, inCountry: country, ofEntity: entity)
    }

    /// Builds the lookup URL for an app.
    ///
    /// - Parameters:
    ///   - appID: MAS app identifier.
    ///   - country: 2-letter ISO region code of the MAS in which to search.
    ///   - entity: OS platform of apps for which to search.
    /// - Returns: URL for the lookup service or nil if appID can't be encoded.
    func lookupURL(
        forAppID appID: AppID,
        inCountry country: String?,
        ofEntity entity: Entity = .desktopSoftware
    ) -> URL? {
        url(.lookup, String(appID), inCountry: country, ofEntity: entity)
    }

    private func url(
        _ action: URLAction,
        _ queryItemValue: String,
        inCountry country: String?,
        ofEntity entity: Entity = .desktopSoftware
    ) -> URL? {
        guard var components = URLComponents(string: "https://itunes.apple.com/\(action)") else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "entity", value: entity.rawValue),
        ]

        if let country {
            components.queryItems!.append(URLQueryItem(name: "country", value: country))
        }

        components.queryItems!.append(URLQueryItem(name: action.queryItemName, value: queryItemValue))

        return components.url
    }
}
