//
//  Search.swift
//  mas
//
//  Created by Michael Schneider on 4/14/16.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension Mas {
    /// Search the Mac App Store using the iTunes Search API:
    /// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
    struct Search: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Search for apps from the Mac App Store"
        )

        @Flag(help: "Show price of found apps")
        var price = false
        @Argument(help: "the app name to search")
        var appName: String

        func run() throws {
            let result = run(storeSearch: MasStoreSearch())
            if case .failure = result {
                try result.get()
            }
        }

        func run(storeSearch: StoreSearch) -> Result<Void, MASError> {
            do {
                let results = try storeSearch.search(for: appName).wait()
                if results.isEmpty {
                    return .failure(.noSearchResultsFound)
                }

                let output = SearchResultFormatter.format(results: results, includePrice: price)
                print(output)

                return .success(())
            } catch {
                // Bubble up MASErrors
                if let error = error as? MASError {
                    return .failure(error)
                }
                return .failure(.searchFailed)
            }
        }
    }
}
