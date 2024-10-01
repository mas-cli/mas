//
//  Info.swift
//  mas
//
//  Created by Denis Lebedev on 21/10/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import Foundation

extension Mas {
    /// Displays app details. Uses the iTunes Lookup API:
    /// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#lookup
    struct Info: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display app information from the Mac App Store"
        )

        @Argument(help: "ID of app to show info")
        var appId: Int

        /// Runs the command.
        func run() throws {
            let result = run(storeSearch: MasStoreSearch())
            if case .failure = result {
                try result.get()
            }
        }

        func run(storeSearch: StoreSearch) -> Result<Void, MASError> {
            do {
                guard let result = try storeSearch.lookup(app: appId).wait() else {
                    return .failure(.noSearchResultsFound)
                }

                print(AppInfoFormatter.format(app: result))
            } catch {
                // Bubble up MASErrors
                if let error = error as? MASError {
                    return .failure(error)
                }
                return .failure(.searchFailed)
            }

            return .success(())
        }
    }
}
