//
//  ITunesSearchAppStoreSearcher.swift
//  mas
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit
import Regex
import Version

/// Manages searching the MAS catalog through the iTunes Search and Lookup APIs.
class ITunesSearchAppStoreSearcher: AppStoreSearcher {
    private static let appVersionExpression = Regex(#"\"versionDisplay\"\:\"([^\"]+)\""#)

    // CommerceKit and StoreFoundation don't seem to expose the region of the Apple ID signed
    // into the App Store. Instead, we'll make an educated guess that it matches the currently
    // selected locale in macOS. This obviously isn't always going to match, but it's probably
    // better than passing no "country" at all to the iTunes Search API.
    // https://performance-partners.apple.com/search-api
    private let country: String?
    private let networkManager: NetworkManager

    /// Designated initializer.
    init(
        country: String? = Locale.autoupdatingCurrent.regionCode,
        networkManager: NetworkManager = NetworkManager()
    ) {
        self.country = country
        self.networkManager = networkManager
    }

    /// Looks up app details.
    ///
    /// - Parameter appID: App ID.
    /// - Returns: A `Promise` for the `SearchResult` for the given `appID`, `nil` if no apps match,
    ///   or an `Error` if any problems occur.
    func lookup(appID: AppID) -> Promise<SearchResult?> {
        guard let url = lookupURL(forAppID: appID, inCountry: country) else {
            fatalError("Failed to build URL for \(appID)")
        }
        return firstly {
            loadSearchResults(url)
        }
        .then { results -> Guarantee<SearchResult?> in
            guard let result = results.first else {
                return .value(nil)
            }

            guard let pageURL = URL(string: result.trackViewUrl) else {
                return .value(result)
            }

            return firstly {
                self.scrapeAppStoreVersion(pageURL)
            }
            .map { pageVersion in
                guard
                    let pageVersion,
                    let searchVersion = Version(tolerant: result.version),
                    pageVersion > searchVersion
                else {
                    return result
                }

                // Update the search result with the version from the App Store page.
                var result = result
                result.version = pageVersion.description
                return result
            }
            .recover { _ in
                // If we were unable to scrape the App Store page, assume compatibility.
                .value(result)
            }
        }
    }

    /// Searches for apps from the MAS.
    ///
    /// - Parameter searchTerm: Term for which to search in the MAS.
    /// - Returns: A `Promise` of an `Array` of `SearchResult`s matching `searchTerm`.
    func search(for searchTerm: String) -> Promise<[SearchResult]> {
        // Search for apps for compatible platforms, in order of preference.
        // Macs with Apple Silicon can run iPad and iPhone apps.
        var entities = [Entity.desktopSoftware]
        if SysCtlSystemCommand.isAppleSilicon {
            entities += [.iPadSoftware, .iPhoneSoftware]
        }

        let results = entities.map { entity in
            guard let url = searchURL(for: searchTerm, inCountry: country, ofEntity: entity) else {
                fatalError("Failed to build URL for \(searchTerm)")
            }
            return loadSearchResults(url)
        }

        // Combine the results, removing any duplicates.
        var seenAppIDs = Set<AppID>()
        return when(fulfilled: results)
            .flatMapValues { $0 }
            .filterValues { result in
                seenAppIDs.insert(result.trackId).inserted
            }
    }

    private func loadSearchResults(_ url: URL) -> Promise<[SearchResult]> {
        firstly {
            networkManager.loadData(from: url)
        }
        .map { data in
            do {
                return try JSONDecoder().decode(SearchResultList.self, from: data).results
            } catch {
                throw MASError.jsonParsing(data: data)
            }
        }
    }

    /// Scrape the app version from the App Store webpage at the given URL.
    ///
    /// App Store webpages frequently report a version that is newer than what is reported by the iTunes Search API.
    private func scrapeAppStoreVersion(_ pageURL: URL) -> Promise<Version?> {
        firstly {
            networkManager.loadData(from: pageURL)
        }
        .map { data in
            guard
                let html = String(data: data, encoding: .utf8),
                let capture = Self.appVersionExpression.firstMatch(in: html)?.captures[0],
                let version = Version(tolerant: capture)
            else {
                return nil
            }

            return version
        }
    }

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
    ///   - appID: App ID.
    ///   - country: 2-letter ISO region code of the MAS in which to search.
    ///   - entity: OS platform of apps for which to search.
    /// - Returns: URL for the lookup service or nil if appID can't be encoded.
    private func lookupURL(
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

        var queryItems = [
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "entity", value: entity.rawValue),
        ]

        if let country {
            queryItems.append(URLQueryItem(name: "country", value: country))
        }

        queryItems.append(URLQueryItem(name: action.queryItemName, value: queryItemValue))

        components.queryItems = queryItems

        return components.url
    }
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
