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
        var failure: MASError?
        let group = DispatchGroup()
        for installedApp in appLibrary.installedApps {
            group.enter()
            storeSearch.lookup(app: installedApp.itemIdentifier.intValue) { storeApp, error in
                defer { group.leave() }

                if let error = error {
                    // Bubble up MASErrors
                    failure = error as? MASError ?? .searchFailed
                    return
                }

                guard let storeApp = storeApp else {
                    printWarning(
                        """
                        Identifier \(installedApp.itemIdentifier) not found in store. \
                        Was expected to identify \(installedApp.appName).
                        """)
                    return
                }

                if installedApp.isOutdatedWhenComparedTo(storeApp) {
                    print(
                        """
                        \(installedApp.itemIdentifier) \(installedApp.appName) \
                        (\(installedApp.bundleVersion) -> \(storeApp.version))
                        """)
                }
            }
        }

        group.wait()

        if let failure = failure {
            return .failure(failure)
        }

        return .success(())
    }
}
