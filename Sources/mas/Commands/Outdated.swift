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

import enum Swift.Result

extension Mas {
    /// Command which displays a list of installed apps which have available updates
    /// ready to be installed from the Mac App Store.
    struct Outdated: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Lists pending updates from the Mac App Store"
        )

        @Flag(help: "Show warnings about apps")
        var verbose = false

        /// Runs the command.
        func run() throws {
            try run(appLibrary: MasAppLibrary(), storeSearch: MasStoreSearch())
        }

        func run(appLibrary: AppLibrary, storeSearch: StoreSearch) throws {
            _ = try when(
                fulfilled:
                    appLibrary.installedApps.map { installedApp in
                        firstly {
                            storeSearch.lookup(app: installedApp.itemIdentifier.intValue)
                        }.done { storeApp in
                            guard let storeApp else {
                                if verbose {
                                    printWarning(
                                        """
                                        Identifier \(installedApp.itemIdentifier) not found in store. \
                                        Was expected to identify \(installedApp.appName).
                                        """
                                    )
                                }
                                return
                            }

                            if installedApp.isOutdatedWhenComparedTo(storeApp) {
                                print(
                                    """
                                    \(installedApp.itemIdentifier) \(installedApp.appName) \
                                    (\(installedApp.bundleVersion) -> \(storeApp.version))
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
