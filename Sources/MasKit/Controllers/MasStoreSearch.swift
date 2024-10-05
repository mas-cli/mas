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
    private static let appVersionExpression = Regex(#"\"versionDisplay\"\:\"([^\"]+)\""#)

    // CommerceKit and StoreFoundation don't seem to expose the region of the Apple ID signed
    // into the App Store. Instead, we'll make an educated guess that it matches the currently
    // selected locale in macOS. This obviously isn't always going to match, but it's probably
    // better than passing no "country" at all to the iTunes Search API.
    // https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
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
            guard let url = searchURL(for: appName, inCountry: country, ofEntity: entity) else {
                fatalError("Failed to build URL for \(appName)")
            }
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
        guard let url = lookupURL(forApp: appId, inCountry: country) else {
            fatalError("Failed to build URL for \(appId)")
        }
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
            guard let html = String(data: data, encoding: .utf8),
                let capture = MasStoreSearch.appVersionExpression.firstMatch(in: html)?.captures[0],
                let version = Version(tolerant: capture)
            else {
                return nil
            }

            return version
        }
    }
}
