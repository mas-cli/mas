//
//  Upgrade.swift
//  mas
//
//  Created by Andrew Naylor on 30/12/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import Foundation
import PromiseKit

extension MAS {
    /// Command which upgrades apps with new versions available in the Mac App Store.
    struct Upgrade: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Upgrade outdated app(s) installed from the Mac App Store"
        )

        @Argument(help: ArgumentHelp("App ID/app name", valueName: "app-id-or-name"))
        var appIDOrNames: [String] = []

        /// Runs the command.
        func run() throws {
            try run(appLibrary: SoftwareMapAppLibrary(), searcher: ITunesSearchAppStoreSearcher())
        }

        func run(appLibrary: AppLibrary, searcher: AppStoreSearcher) throws {
            let apps: [(installedApp: SoftwareProduct, storeApp: SearchResult)]
            do {
                apps = try findOutdatedApps(appLibrary: appLibrary, searcher: searcher)
            } catch {
                throw error as? MASError ?? .searchFailed
            }

            guard !apps.isEmpty else {
                return
            }

            print("Upgrading \(apps.count) outdated application\(apps.count > 1 ? "s" : ""):")
            print(
                apps.map { "\($0.installedApp.appName) (\($0.installedApp.bundleVersion)) -> (\($0.storeApp.version))" }
                    .joined(separator: "\n")
            )

            do {
                try downloadApps(withAppIDs: apps.map(\.installedApp.itemIdentifier.appIDValue)).wait()
            } catch {
                throw error as? MASError ?? .downloadFailed(error: error as NSError)
            }
        }

        private func findOutdatedApps(
            appLibrary: AppLibrary,
            searcher: AppStoreSearcher
        ) throws -> [(SoftwareProduct, SearchResult)] {
            let apps =
                appIDOrNames.isEmpty
                ? appLibrary.installedApps
                : appIDOrNames.flatMap { appIDOrName in
                    if let appID = AppID(appIDOrName) {
                        // argument is an AppID, lookup apps by id using argument
                        let installedApps = appLibrary.installedApps(withAppID: appID)
                        if installedApps.isEmpty {
                            printError(appID.unknownMessage)
                        }
                        return installedApps
                    }

                    // argument is not an AppID, lookup apps by name using argument
                    let installedApps = appLibrary.installedApps(named: appIDOrName)
                    if installedApps.isEmpty {
                        printError("Unknown app name '\(appIDOrName)'")
                    }
                    return installedApps
                }

            let promises = apps.map { installedApp in
                // only upgrade apps whose local version differs from the store version
                searcher.lookup(appID: installedApp.itemIdentifier.appIDValue)
                    .map { storeApp -> (SoftwareProduct, SearchResult)? in
                        guard installedApp.isOutdatedWhenComparedTo(storeApp) else {
                            return nil
                        }
                        return (installedApp, storeApp)
                    }
                    .recover { error -> Promise<(SoftwareProduct, SearchResult)?> in
                        guard case MASError.unknownAppID = error else {
                            return Promise(error: error)
                        }
                        return .value(nil)
                    }
            }

            return try when(fulfilled: promises).wait().compactMap { $0 }
        }
    }
}
