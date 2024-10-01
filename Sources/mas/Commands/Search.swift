//
//  Search.swift
//  mas
//
//  Created by Michael Schneider on 4/14/16.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Commandant

/// Search the Mac App Store using the iTunes Search API:
/// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/
public struct SearchCommand: CommandProtocol {
    public typealias Options = SearchOptions
    public let verb = "search"
    public let function = "Search for apps from the Mac App Store"

    private let storeSearch: StoreSearch

    public init() {
        self.init(storeSearch: MasStoreSearch())
    }

    /// Designated initializer.
    ///
    /// - Parameter storeSearch: Search manager.
    init(storeSearch: StoreSearch = MasStoreSearch()) {
        self.storeSearch = storeSearch
    }

    public func run(_ options: Options) -> Result<Void, MASError> {
        do {
            let results = try storeSearch.search(for: options.appName).wait()
            if results.isEmpty {
                return .failure(.noSearchResultsFound)
            }

            let output = SearchResultFormatter.format(results: results, includePrice: options.price)
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

public struct SearchOptions: OptionsProtocol {
    let appName: String
    let price: Bool

    public static func create(_ appName: String) -> (_ price: Bool) -> SearchOptions {
        { price in
            SearchOptions(appName: appName, price: price)
        }
    }

    public static func evaluate(_ mode: CommandMode) -> Result<SearchOptions, CommandantError<MASError>> {
        create
            <*> mode <| Argument(usage: "the app name to search")
            <*> mode <| Option(key: "price", defaultValue: false, usage: "Show price of found apps")
    }
}
