//
//  Install.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import Foundation

extension MAS {
    /// Installs previously purchased apps from the Mac App Store.
    struct Install: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Install previously purchased app(s) from the Mac App Store"
        )

        @Flag(help: "Force reinstall")
        var force = false
        @Argument(help: ArgumentHelp("App ID", valueName: "app-id"))
        var appIDs: [AppID]

        /// Runs the command.
        func run() async throws {
            try await run(appLibrary: SoftwareMapAppLibrary(), searcher: ITunesSearchAppStoreSearcher())
        }

        func run(appLibrary: AppLibrary, searcher: AppStoreSearcher) async throws {
            // Try to download applications with given identifiers and collect results
            let appIDs = appIDs.filter { appID in
                if let displayName = appLibrary.installedApps(withAppID: appID).first?.displayName, !force {
                    printWarning("\(displayName) is already installed")
                    return false
                }

                return true
            }

            do {
                try await downloadApps(withAppIDs: appIDs, verifiedBy: searcher)
            } catch {
                throw error as? MASError ?? .downloadFailed(error: error as NSError)
            }
        }
    }
}
