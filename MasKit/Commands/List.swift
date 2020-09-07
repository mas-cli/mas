//
//  List.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Commandant

/// Command which lists all installed apps.
public struct ListCommand: CommandProtocol {
    public typealias Options = NoOptions<MASError>
    public let verb = "list"
    public let function = "Lists apps from the Mac App Store which are currently installed"

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
        let products = appLibrary.installedApps
        if products.isEmpty {
            print("No installed apps found")
            return .success(())
        }
        for product in products {
            var appName = product.appName
            if appName == "" {
                appName = product.bundleIdentifier
            }
            print("\(product.itemIdentifier) \(appName) (\(product.bundleVersion))")
        }
        return .success(())
    }
}
