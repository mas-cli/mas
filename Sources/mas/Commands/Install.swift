//
//  Install.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import CommerceKit

extension Mas {
    /// Installs previously purchased apps from the Mac App Store.
    struct Install: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Install from the Mac App Store"
        )

        @Flag(help: "force reinstall")
        var force = false
        @Argument(help: "app ID(s) to install")
        var appIDs: [AppID]

        /// Runs the command.
        func run() throws {
            try run(appLibrary: MasAppLibrary())
        }

        func run(appLibrary: AppLibrary) throws {
            // Try to download applications with given identifiers and collect results
            let appIDs = appIDs.filter { appID in
                if let appName = appLibrary.installedApps(withAppID: appID).first?.appName, !force {
                    printWarning("\(appName) is already installed")
                    return false
                }

                return true
            }

            do {
                try downloadAll(appIDs).wait()
            } catch {
                throw error as? MASError ?? .downloadFailed(error: error as NSError)
            }
        }
    }
}
