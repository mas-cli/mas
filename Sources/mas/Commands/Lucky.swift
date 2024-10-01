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
    /// Command which installs the first search result. This is handy as many MAS titles
    /// can be long with embedded keywords.
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
            let result = run(appLibrary: MasAppLibrary(), storeSearch: MasStoreSearch())
            if case .failure = result {
                try result.get()
            }
        }

        func run(appLibrary: AppLibrary, storeSearch: StoreSearch) -> Result<Void, MASError> {
            var appId: Int?

            do {
                let results = try storeSearch.search(for: appName).wait()
                guard let result = results.first else {
                    printError("No results found")
                    return .failure(.noSearchResultsFound)
                }

                appId = result.trackId
            } catch {
                // Bubble up MASErrors
                if let error = error as? MASError {
                    return .failure(error)
                }
                return .failure(.searchFailed)
            }

            guard let identifier = appId else { fatalError() }

            return install(UInt64(identifier), appLibrary: appLibrary)
        }

        /// Installs an app.
        ///
        /// - Parameters:
        ///   - appId: App identifier
        ///   - appLibrary: Library of installed apps
        /// - Returns: Result of the operation.
        fileprivate func install(_ appId: UInt64, appLibrary: AppLibrary) -> Result<Void, MASError> {
            // Try to download applications with given identifiers and collect results
            if let product = appLibrary.installedApp(forId: appId), !force {
                printWarning("\(product.appName) is already installed")
                return .success(())
            }

            do {
                try downloadAll([appId]).wait()
            } catch {
                return .failure(error as? MASError ?? .downloadFailed(error: error as NSError))
            }

            return .success(())
        }
    }
}
