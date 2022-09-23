//
//  Upgrade.swift
//  mas-cli
//
//  Created by Andrew Naylor on 30/12/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import Foundation
import PromiseKit

import enum Swift.Result

/// Command which upgrades apps with new versions available in the Mac App Store.
public struct UpgradeCommand: CommandProtocol {
    public typealias Options = UpgradeOptions
    public let verb = "upgrade"
    public let function = "Upgrade outdated apps from the Mac App Store"

    private let appLibrary: AppLibrary
    private let storeSearch: StoreSearch

    /// Public initializer.
    public init() {
        self.init(appLibrary: MasAppLibrary())
    }

    /// Internal initializer.
    /// - Parameter appLibrary: AppLibrary manager.
    /// - Parameter storeSearch: StoreSearch manager.
    init(appLibrary: AppLibrary = MasAppLibrary(), storeSearch: StoreSearch = MasStoreSearch()) {
        self.appLibrary = appLibrary
        self.storeSearch = storeSearch
    }

    /// Runs the command.
    public func run(_ options: Options) -> Result<Void, MASError> {
        let apps: [(installedApp: SoftwareProduct, storeApp: SearchResult)]
        do {
            apps = try findOutdatedApps(options)
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

    private func findOutdatedApps(_ options: Options) throws -> [(SoftwareProduct, SearchResult)] {
        let apps: [SoftwareProduct] = options.apps.isEmpty
            ? appLibrary.installedApps
            :
                options.apps.compactMap {
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

public struct UpgradeOptions: OptionsProtocol {
    let apps: [String]

    static func create(_ apps: [String]) -> UpgradeOptions {
        UpgradeOptions(apps: apps)
    }

    public static func evaluate(_ mode: CommandMode) -> Result<UpgradeOptions, CommandantError<MASError>> {
        create
            <*> mode <| Argument(defaultValue: [], usage: "app(s) to upgrade")
    }
}
