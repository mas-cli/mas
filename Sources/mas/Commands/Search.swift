//
//  Search.swift
//  mas
//
//  Created by Michael Schneider on 4/14/16.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension MAS {
    /// Search the Mac App Store using the iTunes Search API.
    ///
    /// See - https://performance-partners.apple.com/search-api
    struct Search: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Search for apps from the Mac App Store"
        )

        @Flag(help: "Show price of found apps")
        var price = false
        @Argument(help: "the app name to search")
        var searchTerm: String

        func run() throws {
            try run(storeSearch: MasStoreSearch())
        }

        func run(storeSearch: StoreSearch) throws {
            do {
                let results = try storeSearch.search(for: searchTerm).wait()
                if results.isEmpty {
                    throw MASError.noSearchResultsFound
                }

                let output = SearchResultFormatter.format(results: results, includePrice: price)
                print(output)
            } catch {
                throw error as? MASError ?? .searchFailed
            }
        }
    }
}
