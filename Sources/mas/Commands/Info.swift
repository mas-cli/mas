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
    /// https://performance-partners.apple.com/search-api
    struct Info: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display app information from the Mac App Store"
        )

        @Argument(help: "ID of app to show info")
        var appID: AppID

        /// Runs the command.
        func run() throws {
            try run(storeSearch: MasStoreSearch())
        }

        func run(storeSearch: StoreSearch) throws {
            do {
                guard let result = try storeSearch.lookup(appID: appID).wait() else {
                    throw MASError.noSearchResultsFound
                }

                print(AppInfoFormatter.format(app: result))
            } catch {
                throw error as? MASError ?? .searchFailed
            }
        }
    }
}
