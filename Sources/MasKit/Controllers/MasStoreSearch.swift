//
//  MasStoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit
import Regex
import Version

/// Manages searching the MAS catalog through the iTunes Search and Lookup APIs.
class MasStoreSearch: StoreSearch {
    private let networkManager: NetworkManager
    private static let appVersionExpression = Regex(#"\"versionDisplay\"\:\"([^\"]+)\""#)

    enum Entity: String {
        case macSoftware
        case iPadSoftware
        case iPhoneSoftware = "software"
    }

    /// Designated initializer.
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    /// Builds the search URL for an app.
    ///
    /// - Parameter appName: MAS app identifier.
    /// - Returns: URL for the search service or nil if appName can't be encoded.
    static func searchURL(for appName: String, ofEntity entity: Entity = .macSoftware) -> URL {
        guard var components = URLComponents(string: "https://itunes.apple.com/search") else {
            fatalError("URLComponents failed to parse URL.")
        }

        components.queryItems = [
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "entity", value: entity.rawValue),
            URLQueryItem(name: "term", value: appName),
        ]
        guard let url = components.url else {
            fatalError("URLComponents failed to generate URL.")
        }

        return url
    }

    /// Builds the lookup URL for an app.
    ///
    /// - Parameter appId: MAS app identifier.
    /// - Returns: URL for the lookup service or nil if appId can't be encoded.
    static func lookupURL(forApp appId: Int) -> URL {
        guard var components = URLComponents(string: "https://itunes.apple.com/lookup") else {
            fatalError("URLComponents failed to parse URL.")
        }

        components.queryItems = [URLQueryItem(name: "id", value: "\(appId)")]
        guard let url = components.url else {
            fatalError("URLComponents failed to generate URL.")
        }

        return url
    }

    /// Searches for an app.
    ///
    /// - Parameter appName: MAS ID of app
    /// - Parameter completion: A closure that receives the search results or an Error if there is a
    ///   problem with the network request. Results array will be empty if there were no matches.
    func search(for appName: String) -> Promise<[SearchResult]> {
        // Search for apps for compatible platforms, in order of preference.
        // Macs with Apple Silicon can run iPad and iPhone apps.
        var entities = [Entity.macSoftware]
        if SysCtlSystemCommand.isAppleSilicon {
            entities += [.iPadSoftware, .iPhoneSoftware]
        }

        let results = entities.map { entity -> Promise<[SearchResult]> in
            let url = MasStoreSearch.searchURL(for: appName, ofEntity: entity)
            return loadSearchResults(url)
        }

        // Combine the results, removing any duplicates.
        var seenAppIDs = Set<Int>()
        return when(fulfilled: results).flatMapValues { $0 }.filterValues { result in
            seenAppIDs.insert(result.trackId).inserted
        }
    }

    /// Looks up app details.
    ///
    /// - Parameter appId: MAS ID of app
    /// - Returns: A Promise for the search result record of app, or nil if no apps match the ID,
    ///   or an Error if there is a problem with the network request.
    func lookup(app appId: Int) -> Promise<SearchResult?> {
        let url = MasStoreSearch.lookupURL(forApp: appId)
        return firstly {
            loadSearchResults(url)
        }.then { results -> Guarantee<SearchResult?> in
            guard let result = results.first else {
                return .value(nil)
            }

            guard let pageUrl = URL(string: result.trackViewUrl)
            else {
                return .value(result)
            }

            return firstly {
                self.scrapeAppStoreVersion(pageUrl)
            }.map { pageVersion in
                guard let pageVersion,
                    let searchVersion = Version(tolerant: result.version),
                    pageVersion > searchVersion
                else {
                    return result
                }

                // Update the search result with the version from the App Store page.
                var result = result
                result.version = pageVersion.description
                return result
            }.recover { _ in
                // If we were unable to scrape the App Store page, assume compatibility.
                .value(result)
            }
        }
    }

    private func loadSearchResults(_ url: URL) -> Promise<[SearchResult]> {
        firstly {
            networkManager.loadData(from: url)
        }.map { data -> [SearchResult] in
            do {
                return try JSONDecoder().decode(SearchResultList.self, from: data).results
            } catch {
                throw MASError.jsonParsing(error: error as NSError)
            }
        }
    }

    // App Store pages indicate:
    // - compatibility with Macs with Apple Silicon
    // - (often) a version that is newer than what is listed in search results
    //
    // We attempt to scrape this information here.
    private func scrapeAppStoreVersion(_ pageUrl: URL) -> Promise<Version?> {
        firstly {
            networkManager.loadData(from: pageUrl)
        }.map { data in
            let html = String(decoding: data, as: UTF8.self)
            guard let capture = MasStoreSearch.appVersionExpression.firstMatch(in: html)?.captures[0],
                let version = Version(tolerant: capture)
            else {
                return nil
            }

            return version
        }
    }
}
