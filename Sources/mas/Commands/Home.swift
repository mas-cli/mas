//
//  Home.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2016 mas-cli. All rights reserved.
//

import ArgumentParser

extension Mas {
    /// Opens app page on MAS Preview. Uses the iTunes Lookup API:
    /// https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/#lookup
    struct Home: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Opens MAS Preview app page in a browser"
        )

        @Argument(help: "ID of app to show on MAS Preview")
        var appId: Int

        /// Runs the command.
        func run() throws {
            let result = run(storeSearch: MasStoreSearch(), openCommand: OpenSystemCommand())
            if case .failure = result {
                try result.get()
            }
        }

        func run(storeSearch: StoreSearch, openCommand: ExternalCommand) -> Result<Void, MASError> {
            do {
                guard let result = try storeSearch.lookup(app: appId).wait() else {
                    return .failure(.noSearchResultsFound)
                }

                do {
                    try openCommand.run(arguments: result.trackViewUrl)
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
