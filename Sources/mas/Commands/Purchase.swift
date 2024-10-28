//
//  Purchase.swift
//  mas
//
//  Created by Jakob Rieck on 24/10/2017.
//  Copyright (c) 2017 Jakob Rieck. All rights reserved.
//

import ArgumentParser
import CommerceKit

extension MAS {
    struct Purchase: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "\"Purchase\" and install free apps from the Mac App Store"
        )

        @Argument(help: "App ID(s)")
        var appIDs: [AppID]

        /// Runs the command.
        func run() throws {
            try run(appLibrary: SoftwareMapAppLibrary())
        }

        func run(appLibrary: AppLibrary) throws {
            // Try to download applications with given identifiers and collect results
            let appIDs = appIDs.filter { appID in
                if let appName = appLibrary.installedApps(withAppID: appID).first?.appName {
                    printWarning("\(appName) has already been purchased.")
                    return false
                }

                return true
            }

            do {
                try downloadApps(withAppIDs: appIDs, purchasing: true).wait()
            } catch {
                throw error as? MASError ?? .downloadFailed(error: error as NSError)
            }
        }
    }
}
