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

extension Mas {
    /// Command which upgrades apps with new versions available in the Mac App Store.
    struct Upgrade: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Upgrade outdated apps from the Mac App Store"
        )

        @Argument(help: "app(s) to upgrade")
        var appIDs: [String] = []

        /// Runs the command.
        func run() throws {
            try run(appLibrary: MasAppLibrary(), storeSearch: MasStoreSearch())
        }

        func run(appLibrary: AppLibrary, storeSearch: StoreSearch) throws {
            let apps: [(installedApp: SoftwareProduct, storeApp: SearchResult)]
            do {
                apps = try findOutdatedApps(appLibrary: appLibrary, storeSearch: storeSearch)
            } catch {
                throw error as? MASError ?? .searchFailed
            }

            guard !apps.isEmpty else {
                printWarning("Nothing found to upgrade")
                return
            }

            print("Upgrading \(apps.count) outdated application\(apps.count > 1 ? "s" : ""):")
            print(
                apps.map { "\($0.installedApp.appName) (\($0.installedApp.bundleVersion)) -> (\($0.storeApp.version))" }
                    .joined(separator: "\n")
            )

            do {
                try downloadAll(apps.map(\.installedApp.itemIdentifier.appIDValue)).wait()
            } catch {
                throw error as? MASError ?? .downloadFailed(error: error as NSError)
            }
        }

        private func findOutdatedApps(
            appLibrary: AppLibrary,
            storeSearch: StoreSearch
        ) throws -> [(SoftwareProduct, SearchResult)] {
            let apps: [SoftwareProduct] =
                appIDs.isEmpty
                ? appLibrary.installedApps
                : appIDs.compactMap {
                    if let appID = AppID($0) {
                        // argument is an AppID, lookup app by id using argument
                        return appLibrary.installedApp(withAppID: appID)
                    }

                    // argument is not an AppID, lookup app by name using argument
                    return appLibrary.installedApp(named: $0)
                }

            let promises = apps.map { installedApp in
                // only upgrade apps whose local version differs from the store version
                firstly {
                    storeSearch.lookup(appID: installedApp.itemIdentifier.appIDValue)
                }
                .map { result -> (SoftwareProduct, SearchResult)? in
                    guard let storeApp = result, installedApp.isOutdatedWhenComparedTo(storeApp) else {
                        return nil
                    }

                    return (installedApp, storeApp)
                }
            }

            return try when(fulfilled: promises).wait().compactMap { $0 }
        }
    }
}
