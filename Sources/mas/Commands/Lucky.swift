//
//  Lucky.swift
//  mas
//
//  Created by Pablo Varela on 05/11/17.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import CommerceKit

extension Mas {
    /// Command which installs the first search result.
    ///
    /// This is handy as many MAS titles can be long with embedded keywords.
    struct Lucky: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Install the first result from the Mac App Store"
        )

        @Flag(help: "force reinstall")
        var force = false
        @Argument(help: "the app name to install")
        var appName: String

        /// Runs the command.
        func run() throws {
            try run(appLibrary: MasAppLibrary(), storeSearch: MasStoreSearch())
        }

        func run(appLibrary: AppLibrary, storeSearch: StoreSearch) throws {
            var appID: AppID?

            do {
                let results = try storeSearch.search(for: appName).wait()
                guard let result = results.first else {
                    printError("No results found")
                    throw MASError.noSearchResultsFound
                }

                appID = result.trackId
            } catch {
                throw error as? MASError ?? .searchFailed
            }

            guard let appID else {
                fatalError()
            }

            try install(appID: appID, appLibrary: appLibrary)
        }

        /// Installs an app.
        ///
        /// - Parameters:
        ///   - appID: App identifier
        ///   - appLibrary: Library of installed apps
        /// - Throws: Any error that occurs while attempting to install the app.
        private func install(appID: AppID, appLibrary: AppLibrary) throws {
            // Try to download applications with given identifiers and collect results
            if let product = appLibrary.installedApp(withAppID: appID), !force {
                printWarning("\(product.appName) is already installed")
            } else {
                do {
                    try downloadAll([appID]).wait()
                } catch {
                    throw error as? MASError ?? .downloadFailed(error: error as NSError)
                }
            }
        }
    }
}
