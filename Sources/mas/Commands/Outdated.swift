//
//  Outdated.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import Foundation
import PromiseKit

extension MAS {
    /// Command which displays a list of installed apps which have available updates
    /// ready to be installed from the Mac App Store.
    struct Outdated: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "List pending app updates from the Mac App Store"
        )

        @Flag(help: "Display warnings about apps unknown to the Mac App Store")
        var verbose = false

        /// Runs the command.
        func run() throws {
            try run(appLibrary: SoftwareMapAppLibrary(), searcher: ITunesSearchAppStoreSearcher())
        }

        func run(appLibrary: AppLibrary, searcher: AppStoreSearcher) throws {
            _ = try when(
                fulfilled:
                    appLibrary.installedApps.map { installedApp in
                        searcher.lookup(appID: installedApp.itemIdentifier.appIDValue)
                            .done { storeApp in
                                if installedApp.isOutdated(comparedTo: storeApp) {
                                    print(
                                        """
                                        \(installedApp.itemIdentifier) \(installedApp.displayName) \
                                        (\(installedApp.bundleVersion) -> \(storeApp.version))
                                        """
                                    )
                                }
                            }
                            .recover { error in
                                guard case MASError.unknownAppID = error else {
                                    throw error
                                }

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
            )
            .wait()
        }
    }
}
