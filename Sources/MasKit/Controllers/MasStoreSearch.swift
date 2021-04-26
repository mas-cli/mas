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

        loadSearchResults(url) { results, error in
            if let error = error {
                completion(nil, error)
                return
            }

            completion(results, nil)
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

        loadSearchResults(url) { results, error in
            if let error = error {
                completion(nil, error)
                return
            }

            completion(results?.first, nil)
        }
    }

    private func loadSearchResults(_ url: URL, _ completion: @escaping ([SearchResult]?, Error?) -> Void) {
        networkManager.loadData(from: url) { data, error in
            guard let data = data else {
                if let error = error {
                    completion(nil, error)
                } else {
                    completion(nil, MASError.noData)
                }

                return
            }

            var results: SearchResultList
            do {
                results = try JSONDecoder().decode(SearchResultList.self, from: data)
            } catch {
                completion(nil, MASError.jsonParsing(error: error as NSError))
                return
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
                self.scrapeVersionFromPage(pageUrl) { pageVersion in
                    if let pageVersion = pageVersion, pageVersion > searchVersion {
                        results.results[index].version = pageVersion.description
                    }

                    group.leave()
                }
            }

            group.notify(queue: DispatchQueue.global()) {
                completion(results.results, nil)
            }
        }
    }

    // The App Store often lists a newer version available in an app's page than in
    // the search results. We attempt to scrape it here.
    private func scrapeVersionFromPage(_ pageUrl: URL, _ completion: @escaping (Version?) -> Void) {
        networkManager.loadData(from: pageUrl) { data, _ in
            guard let data = data else {
                completion(nil)
                return
            }

            let html = String(decoding: data, as: UTF8.self)
            let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)
            guard let match = MasStoreSearch.versionExpression.firstMatch(in: html, range: fullRange),
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
