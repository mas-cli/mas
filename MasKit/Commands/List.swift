//
//  List.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import Result

/// Command which lists all installed apps.
public struct ListCommand: CommandProtocol {
    public typealias Options = NoOptions<MASError>
    public let verb = "list"
    public let function = "Lists apps from the Mac App Store which are currently installed"

    private let appLibrary: AppLibrary

    /// Designated initializer.
    ///
    /// - Parameter appLibrary: AppLibrary manager.
    public init(appLibrary: AppLibrary = MasAppLibrary()) {
        self.appLibrary = appLibrary
    }

    public func run(_ options: Options) -> Result<(), MASError> {
        let products = appLibrary.installedApps
        if products.isEmpty {
            print("No installed apps found")
            return .success(())
        }
        for product in products {
            print("\(product.itemIdentifier) \(product.appName) (\(product.bundleVersion))")
        }
        return .success(())
    }
}
