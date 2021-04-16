//
//  Outdated.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Commandant

/// Command which displays a list of installed apps which have available updates
/// ready to be installed from the Mac App Store.
public struct OutdatedCommand: CommandProtocol {
    public typealias Options = NoOptions<MASError>
    public let verb = "outdated"
    public let function = "Lists pending updates from the Mac App Store"

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
    public func run(_: Options) -> Result<Void, MASError> {
        for installedApp in appLibrary.installedApps {
            do {
                if let storeApp = try storeSearch.lookup(app: installedApp.itemIdentifier.intValue) {
                    if installedApp.isOutdatedWhenComparedTo(storeApp) {
                        print(
                            """
                            \(installedApp.itemIdentifier) \(installedApp.appName) \
                            (\(installedApp.bundleVersion) -> \(storeApp.version))
                            """)
                    }
                } else {
                    printWarning(
                        """
                        Identifier \(installedApp.itemIdentifier) not found in store. \
                        Was expected to identify \(installedApp.appName).
                        """)
                }
            } catch {
                // Bubble up MASErrors
                return .failure(error as? MASError ?? .searchFailed)
            }
        }
        return .success(())
    }
}
