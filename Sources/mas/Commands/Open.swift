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
            let result = run(storeSearch: MasStoreSearch(), openCommand: OpenSystemCommand())
            if case .failure = result {
                try result.get()
            }
        }

        func run(storeSearch: StoreSearch, openCommand: ExternalCommand) -> Result<Void, MASError> {
            do {
                if appId == markerValue {
                    // If no app ID is given, just open the MAS GUI app
                    try openCommand.run(arguments: masScheme + "://")
                    return .success(())
                }

                guard let appId = Int(appId)
                else {
                    printError("Invalid app ID")
                    return .failure(.noSearchResultsFound)
                }

                guard let result = try storeSearch.lookup(app: appId).wait()
                else {
                    return .failure(.noSearchResultsFound)
                }

                guard var url = URLComponents(string: result.trackViewUrl)
                else {
                    return .failure(.searchFailed)
                }
                url.scheme = masScheme

                do {
                    try openCommand.run(arguments: url.string!)
                } catch {
                    printError("Unable to launch open command")
                    return .failure(.searchFailed)
                }
                if openCommand.failed {
                    let reason = openCommand.process.terminationReason
                    printError("Open failed: (\(reason)) \(openCommand.stderr)")
                    return .failure(.searchFailed)
                }
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
