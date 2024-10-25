//
//  Open.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import ArgumentParser
import Foundation

private let masScheme = "macappstore"

extension MAS {
    /// Opens app page in MAS app. Uses the iTunes Lookup API:
    /// https://performance-partners.apple.com/search-api
    struct Open: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Opens app page in AppStore.app"
        )

        @Argument(help: "the app ID")
        var appID: AppID?

        /// Runs the command.
        func run() throws {
            try run(storeSearch: MasStoreSearch(), openCommand: OpenSystemCommand())
        }

        func run(storeSearch: StoreSearch, openCommand: ExternalCommand) throws {
            do {
                guard let appID else {
                    // If no app ID is given, just open the MAS GUI app
                    try openCommand.run(arguments: masScheme + "://")
                    return
                }

                guard let result = try storeSearch.lookup(appID: appID).wait() else {
                    throw MASError.noSearchResultsFound
                }

                guard var url = URLComponents(string: result.trackViewUrl) else {
                    throw MASError.searchFailed
                }
                url.scheme = masScheme

                guard let urlString = url.string else {
                    printError("Unable to construct URL")
                    throw MASError.searchFailed
                }
                do {
                    try openCommand.run(arguments: urlString)
                } catch {
                    printError("Unable to launch open command")
                    throw MASError.searchFailed
                }
                if openCommand.failed {
                    printError("Open failed: (\(openCommand.process.terminationReason)) \(openCommand.stderr)")
                    throw MASError.searchFailed
                }
            } catch {
                throw error as? MASError ?? .searchFailed
            }
        }
    }
}
