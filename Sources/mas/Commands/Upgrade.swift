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

import enum Swift.Result

extension Mas {
    /// Command which upgrades apps with new versions available in the Mac App Store.
    struct Upgrade: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Upgrade outdated apps from the Mac App Store"
        )

        @Argument(help: "app(s) to upgrade")
        var apps: [String] = []

        /// Runs the command.
        func run() throws {
            let result = run(appLibrary: MasAppLibrary(), storeSearch: MasStoreSearch())
            if case .failure = result {
                try result.get()
            }
        }

        func run(appLibrary: AppLibrary, storeSearch: StoreSearch) -> Result<Void, MASError> {
            let apps: [(installedApp: SoftwareProduct, storeApp: SearchResult)]
            do {
                apps = try findOutdatedApps(appLibrary: appLibrary, storeSearch: storeSearch)
            } catch {
                // Bubble up MASErrors
                return .failure(error as? MASError ?? .searchFailed)
            }

            guard apps.count > 0 else {
                printWarning("Nothing found to upgrade")
                return .success(())
            }

            print("Upgrading \(apps.count) outdated application\(apps.count > 1 ? "s" : ""):")
            print(
                apps.map { "\($0.installedApp.appName) (\($0.installedApp.bundleVersion)) -> (\($0.storeApp.version))" }
                    .joined(separator: "\n"))

            let appIds = apps.map(\.installedApp.itemIdentifier.uint64Value)
            do {
                try downloadAll(appIds).wait()
            } catch {
                return .failure(error as? MASError ?? .downloadFailed(error: error as NSError))
            }

            return .success(())
        }

        private func findOutdatedApps(
            appLibrary: AppLibrary,
            storeSearch: StoreSearch
        ) throws -> [(SoftwareProduct, SearchResult)] {
            let apps: [SoftwareProduct] =
                apps.isEmpty
                ? appLibrary.installedApps
                : apps.compactMap {
                    if let appId = UInt64($0) {
                        // if argument a UInt64, lookup app by id using argument
                        return appLibrary.installedApp(forId: appId)
                    } else {
                        // if argument not a UInt64, lookup app by name using argument
                        return appLibrary.installedApp(named: $0)
                    }
                }

            let promises = apps.map { installedApp in
                // only upgrade apps whose local version differs from the store version
                firstly {
                    storeSearch.lookup(app: installedApp.itemIdentifier.intValue)
                }.map { result -> (SoftwareProduct, SearchResult)? in
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
