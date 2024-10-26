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

        @Flag(help: "Display the price of each app")
        var price = false
        @Argument(help: "Search term")
        var searchTerm: String

        func run() throws {
            try run(searcher: ITunesSearchAppStoreSearcher())
        }

        func run(searcher: AppStoreSearcher) throws {
            do {
                let results = try searcher.search(for: searchTerm).wait()
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
