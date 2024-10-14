//
//  Open.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import ArgumentParser
import Foundation

private let markerValue = "appstore"
private let masScheme = "macappstore"

extension Mas {
    /// Opens app page in MAS app. Uses the iTunes Lookup API:
    /// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#lookup
    struct Open: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Opens app page in AppStore.app"
        )

        @Argument(help: "the app ID")
        var appId: String = markerValue

        /// Runs the command.
        func run() throws {
            try run(storeSearch: MasStoreSearch(), openCommand: OpenSystemCommand())
        }

        func run(storeSearch: StoreSearch, openCommand: ExternalCommand) throws {
            do {
                if appId == markerValue {
                    // If no app ID is given, just open the MAS GUI app
                    try openCommand.run(arguments: masScheme + "://")
                    return
                }

                guard let appId = Int(appId)
                else {
                    printError("Invalid app ID")
                    throw MASError.noSearchResultsFound
                }

                guard let result = try storeSearch.lookup(app: appId).wait()
                else {
                    throw MASError.noSearchResultsFound
                }

                guard var url = URLComponents(string: result.trackViewUrl)
                else {
                    throw MASError.searchFailed
                }
                url.scheme = masScheme

                do {
                    try openCommand.run(arguments: url.string!)
                } catch {
                    printError("Unable to launch open command")
                    throw MASError.searchFailed
                }
                if openCommand.failed {
                    let reason = openCommand.process.terminationReason
                    printError("Open failed: (\(reason)) \(openCommand.stderr)")
                    throw MASError.searchFailed
                }
            } catch {
                throw error as? MASError ?? .searchFailed
            }
        }
    }
}
