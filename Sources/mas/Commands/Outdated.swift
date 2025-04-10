//
//  Outdated.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension MAS {
    /// Command which displays a list of installed apps which have available updates
    /// ready to be installed from the Mac App Store.
    struct Outdated: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "List pending app updates from the Mac App Store"
        )

        @Flag(help: "Display warnings about apps unknown to the Mac App Store")
        var verbose = false

        /// Runs the command.
        func run() async throws {
            try await run(appLibrary: await SoftwareMapAppLibrary(), searcher: ITunesSearchAppStoreSearcher())
        }

        func run(appLibrary: AppLibrary, searcher: AppStoreSearcher) async throws {
            for installedApp in appLibrary.installedApps {
                do {
                    let storeApp = try await searcher.lookup(appID: installedApp.itemIdentifier.appIDValue)
                    if installedApp.isOutdated(comparedTo: storeApp) {
                        print(
                            """
                            \(installedApp.itemIdentifier) \(installedApp.displayName) \
                            (\(installedApp.bundleVersion) -> \(storeApp.version))
                            """
                        )
                    }
                } catch MASError.unknownAppID(_) {
                    if verbose {
                        printWarning(
                            """
                            Identifier \(installedApp.itemIdentifier) not found in store. \
                            Was expected to identify \(installedApp.displayName).
                            """
                        )
                    }
                }
            }
        }
    }
}
