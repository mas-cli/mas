//
//  MasStoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import Version

/// Manages searching the MAS catalog through the iTunes Search and Lookup APIs.
public class MasStoreSearch: StoreSearch {
    private let networkManager: NetworkManager
    private static let versionExpression: NSRegularExpression? = {
        do {
            return try NSRegularExpression(pattern: #"\"versionDisplay\"\:\"([^\"]+)\""#)
        } catch {
            return nil
        }
    }()

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

        return try loadSearchResults(url)
    }

    /// Looks up app details.
    ///
    /// - Parameter appId: MAS ID of app
    /// - Returns: Search result record of app or nil if no apps match the ID.
    /// - Throws: Error if there is a problem with the network request.
    public func lookup(app appId: Int) throws -> SearchResult? {
        guard let url = lookupURL(forApp: appId)
        else { throw MASError.urlEncoding }

        let results = try loadSearchResults(url)
        guard let searchResult = results.results.first
        else { return nil }

        return searchResult
    }

    private func loadSearchResults(_ url: URL) throws -> SearchResultList {
        var results: SearchResultList
        let data = try networkManager.loadDataSync(from: url)
        do {
            results = try JSONDecoder().decode(SearchResultList.self, from: data)
        } catch {
            throw MASError.jsonParsing(error: error as NSError)
        }

        let group = DispatchGroup()
        for index in results.results.indices {
            let result = results.results[index]
            guard let searchVersion = Version(tolerant: result.version),
                let pageUrl = URL(string: result.trackViewUrl)
            else {
                continue
            }

            group.enter()
            scrapeVersionFromPage(pageUrl) { pageVersion in
                if let pageVersion = pageVersion, pageVersion > searchVersion {
                    results.results[index].version = pageVersion.description
                }

                group.leave()
            }
        }

        group.wait()

        return results
    }

    // The App Store often lists a newer version available in an app's page than in
    // the search results. We attempt to scrape it here.
    private func scrapeVersionFromPage(_ pageUrl: URL, _ completion: @escaping (Version?) -> Void) {
        networkManager.loadData(from: pageUrl) { result in
            guard case let .success(pageData) = result else {
                completion(nil)
                return
            }

            let html = String(decoding: pageData, as: UTF8.self)
            let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)
            guard let match = MasStoreSearch.versionExpression?.firstMatch(in: html, range: fullRange),
                let range = Range(match.range(at: 1), in: html),
                let version = Version(tolerant: html[range])
            else {
                completion(nil)
                return
            }

            completion(version)
        }
    }
}
