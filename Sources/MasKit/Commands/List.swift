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
    public func run(_: Options) -> Result<Void, MASError> {
        let products = appLibrary.installedApps
        if products.isEmpty {
            printError("No installed apps found")
            return .success(())
        }

        let output = AppListFormatter.format(products: products)
        print(output)

        return .success(())
    }
}
