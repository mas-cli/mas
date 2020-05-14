//
//  Upgrade.swift
//  mas-cli
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import CommerceKit
import StoreFoundation

/// Command which uninstalls apps managed by the Mac App Store.
public struct UninstallCommand: CommandProtocol {
    public typealias Options = UninstallOptions
    public let verb = "uninstall"
    public let function = "Uninstall app installed from the Mac App Store"

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

    /// Runs the uninstall command.
    ///
    /// - Parameter options: UninstallOptions (arguments) for this command
    /// - Returns: Success or an error.
    public func run(_ options: Options) -> Result<(), MASError> {
        let appId = UInt64(options.appId)

        guard let product = appLibrary.installedApp(forId: appId) else {
            return .failure(.notInstalled)
        }

        if options.dryRun {
            printInfo("\(product.appName) \(product.bundlePath)")
            printInfo("(not removed, dry run)")

            return .success(())
        }

        do {
            try appLibrary.uninstallApp(app: product)
        } catch {
            return .failure(.uninstallFailed)
        }

        return .success(())
    }
}

/// Options for the uninstall command.
public struct UninstallOptions: OptionsProtocol {
    /// Numeric app ID
    let appId: Int

    /// Flag indicating that removal shouldn't be performed
    let dryRun: Bool

    static func create(_ appId: Int) -> (_ dryRun: Bool) -> UninstallOptions {
        return { dryRun in
            UninstallOptions(appId: appId, dryRun: dryRun)
        }
    }

    public static func evaluate(_ mode: CommandMode) -> Result<UninstallOptions, CommandantError<MASError>> {
        return create
            <*> mode <| Argument(usage: "ID of app to uninstall")
            <*> mode <| Switch(flag: nil, key: "dry-run", usage: "dry run")
    }
}
