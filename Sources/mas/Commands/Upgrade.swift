//
//  Upgrade.swift
//  mas
//
//  Created by Andrew Naylor on 30/12/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import Foundation

extension MAS {
    /// Command which upgrades apps with new versions available in the Mac App Store.
    struct Upgrade: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Upgrade outdated app(s) installed from the Mac App Store"
        )

        @Argument(help: ArgumentHelp("App ID/app name", valueName: "app-id-or-name"))
        var appIDOrNames = [String]()

        /// Runs the command.
        func run() async throws {
            try await run(appLibrary: await SoftwareMapAppLibrary(), searcher: ITunesSearchAppStoreSearcher())
        }

        func run(appLibrary: AppLibrary, searcher: AppStoreSearcher) async throws {
            do {
                let apps = try await findOutdatedApps(appLibrary: appLibrary, searcher: searcher)

                guard !apps.isEmpty else {
                    return
                }

                print("Upgrading \(apps.count) outdated application\(apps.count > 1 ? "s" : ""):")
                print(
                    apps.map { installedApp, storeApp in
                        "\(storeApp.trackName) (\(installedApp.bundleVersion)) -> (\(storeApp.version))"
                    }
                    .joined(separator: "\n")
                )

                do {
                    try await downloadApps(withAppIDs: apps.map(\.storeApp.trackId))
                } catch {
                    throw error as? MASError ?? .downloadFailed(error: error as NSError)
                }
            } catch {
                throw error as? MASError ?? .searchFailed
            }
        }

        private func findOutdatedApps(
            appLibrary: AppLibrary,
            searcher: AppStoreSearcher
        ) async throws -> [(installedApp: SoftwareProduct, storeApp: SearchResult)] {
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

            var outdatedApps: [(SoftwareProduct, SearchResult)] = []
            for installedApp in apps {
                let storeApp = try await searcher.lookup(appID: installedApp.itemIdentifier.appIDValue)
                if installedApp.isOutdated(comparedTo: storeApp) {
                    outdatedApps.append((installedApp, storeApp))
                }
            }
            return outdatedApps
        }
    }
}
