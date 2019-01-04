//
//  MasAppLibrary.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import CommerceKit

/// Utility for managing installed apps.
public class MasAppLibrary: AppLibrary {
    /// CommerceKit's singleton manager of installed software.
    private let softwareMap = CKSoftwareMap.shared()

    /// Array of installed software products.
    public lazy var installedApps: [SoftwareProduct] = {
        var appList = [SoftwareProduct]()
        guard let products = softwareMap.allProducts()
            else { return appList }
        appList.append(contentsOf: products)
        return products
    }()

    private var trashCommand: ExternalCommand

    /// Designated initializer
    public init(trashCommand: ExternalCommand = TrashCommand()) {
        self.trashCommand = trashCommand
    }

    /// Finds an app using a bundle identifier.
    ///
    /// - Parameter bundleId: Bundle identifier of app.
    /// - Returns: Software Product of app if found; nil otherwise.
    public func installedApp(forBundleId bundleId: String) -> SoftwareProduct? {
        return softwareMap.product(forBundleIdentifier: bundleId)
    }

    /// Uninstalls an app.
    ///
    /// - Parameter app: App to be removed.
    /// - Throws: Error if there is a problem.
    public func uninstallApp(app: SoftwareProduct) throws {
        do {
            try trashCommand.run(arguments: app.bundlePath)
        } catch {
            printError("Unable to launch trash command")
            throw MASError.uninstallFailed
        }
        if trashCommand.failed {
            let reason = trashCommand.process.terminationReason
            printError("Uninstall failed: (\(reason)) \(trashCommand.stderr)")
            throw MASError.uninstallFailed
        }
    }
}
