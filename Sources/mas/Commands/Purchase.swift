//
//  Purchase.swift
//  mas
//
//  Created by Jakob Rieck on 24/10/2017.
//  Copyright (c) 2017 Jakob Rieck. All rights reserved.
//

import ArgumentParser
import CommerceKit

extension Mas {
    struct Purchase: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Purchase and download free apps from the Mac App Store"
        )

        @Argument(help: "app ID(s) to install")
        var appIDs: [AppID]

        /// Runs the command.
        func run() throws {
            try run(appLibrary: MasAppLibrary())
        }

        func run(appLibrary: AppLibrary) throws {
            // Try to download applications with given identifiers and collect results
            let appIDs = appIDs.filter { appID in
                if let product = appLibrary.installedApp(withAppID: appID) {
                    printWarning("\(product.appName) has already been purchased.")
                    return false
                }

                return true
            }

            do {
                try downloadAll(appIDs, purchase: true).wait()
            } catch {
                throw error as? MASError ?? .downloadFailed(error: error as NSError)
            }
        }
    }
}
