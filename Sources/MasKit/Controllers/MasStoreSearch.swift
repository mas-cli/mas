//
//  MasStoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import PromiseKit
import Version

/// Manages searching the MAS catalog through the iTunes Search and Lookup APIs.
class MasStoreSearch: StoreSearch {
    private let networkManager: NetworkManager
    private static let versionExpression: NSRegularExpression = {
        do {
            return try NSRegularExpression(pattern: #"\"versionDisplay\"\:\"([^\"]+)\""#)
        } catch {
            fatalError("Unexpected error initializing NSRegularExpression: \(error.localizedDescription)")
        }
    }()

    /// Designated initializer.
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    /// Searches for an app.
    ///
    /// - Parameter appName: MAS ID of app
    /// - Parameter completion: A closure that receives the search results or an Error if there is a
    ///   problem with the network request. Results array will be empty if there were no matches.
    func search(for appName: String, _ completion: @escaping ([SearchResult]?, Error?) -> Void) {
        guard let url = searchURL(for: appName)
        else {
            completion(nil, MASError.urlEncoding)
            return
        }

        firstly {
            loadSearchResults(url)
        }.done { results in
            completion(results, nil)
        }.catch { error in
            completion(nil, error)
        }
    }

    /// Looks up app details.
    ///
    /// - Parameter appId: MAS ID of app
    /// - Parameter completion: A closure that receives the search result record of app, or nil if no apps match the ID,
    ///   or an Error if there is a problem with the network request.
    func lookup(app appId: Int, _ completion: @escaping (SearchResult?, Error?) -> Void) {
        guard let url = lookupURL(forApp: appId)
        else {
            completion(nil, MASError.urlEncoding)
            return
        }

        firstly {
            loadSearchResults(url)
        }.done { results in
            completion(results.first, nil)
        }.catch { error in
            completion(nil, error)
        }
    }

    private func loadSearchResults(_ url: URL) -> Promise<[SearchResult]> {
        firstly {
            networkManager.loadData(from: url)
        }.map { data -> SearchResultList in
            do {
                return try JSONDecoder().decode(SearchResultList.self, from: data)
            } catch {
                throw MASError.jsonParsing(error: error as NSError)
            }
        }.then { list -> Promise<[SearchResult]> in
            var results = list.results
            let scraping = results.indices.compactMap { index -> Guarantee<Void>? in
                let result = results[index]
                guard let searchVersion = Version(tolerant: result.version),
                    let pageUrl = URL(string: result.trackViewUrl)
                else {
                    return nil
                }

                return firstly {
                    self.scrapeVersionFromPage(pageUrl)
                }.done { pageVersion in
                    if let pageVersion = pageVersion, pageVersion > searchVersion {
                        results[index].version = pageVersion.description
                    }
                }
            }

            return when(fulfilled: scraping).map { results }
        }
    }

    // The App Store often lists a newer version available in an app's page than in
    // the search results. We attempt to scrape it here.
    private func scrapeVersionFromPage(_ pageUrl: URL) -> Guarantee<Version?> {
        firstly {
            networkManager.loadData(from: pageUrl)
        }.map { data in
            let html = String(decoding: data, as: UTF8.self)
            let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)
            guard let match = MasStoreSearch.versionExpression.firstMatch(in: html, range: fullRange),
                let range = Range(match.range(at: 1), in: html),
                let version = Version(tolerant: html[range])
            else {
                throw MASError.noData
            }

            return version
        }.recover { _ in
            .value(nil)
        }
    }
}
