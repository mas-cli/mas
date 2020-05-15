//
//  Outdated.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import CommerceKit

/// Command which displays a list of installed apps which have available updates
/// ready to be installed from the Mac App Store.
public struct OutdatedCommand: CommandProtocol {
    public typealias Options = NoOptions<MASError>
    public let verb = "outdated"
    public let function = "Lists pending updates from the Mac App Store"

    private let appLibrary: AppLibrary

    /// Public initializer.
    /// - Parameter appLibrary: AppLibrary manager.
    public init() {
        self.init(appLibrary: MasAppLibrary())
    }

    /// Internal initializer.
    /// - Parameter appLibrary: AppLibrary manager.
    init(appLibrary: AppLibrary = MasAppLibrary()) {
        self.appLibrary = appLibrary
    }

    /// Runs the command.
    public func run(_: Options) -> Result<(), MASError> {
        let updateController = CKUpdateController.shared()
        let updates = updateController?.availableUpdates()
        for update in updates! {
            if let installed = appLibrary.installedApp(forBundleId: update.bundleID) {
                // Display version of installed app compared to available update.
                print("""
                \(update.itemIdentifier) \(update.title) (\(installed.bundleVersion) -> \(update.bundleVersion))
                """)
            } else {
                print("\(update.itemIdentifier) \(update.title) (unknown -> \(update.bundleVersion))")
            }
        }
        return .success(())
    }
}
