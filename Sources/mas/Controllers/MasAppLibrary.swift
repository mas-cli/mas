//
//  MasAppLibrary.swift
//  mas
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import CommerceKit

/// Utility for managing installed apps.
class MasAppLibrary: AppLibrary {
    /// CommerceKit's singleton manager of installed software.
    private let softwareMap: SoftwareMap

    /// Array of installed software products.
    lazy var installedApps: [SoftwareProduct] = softwareMap.allSoftwareProducts()
        .filter { product in
            product.bundlePath.starts(with: "/Applications/")
        }

    /// Internal initializer for providing a mock software map.
    /// - Parameter softwareMap: SoftwareMap to use
    init(softwareMap: SoftwareMap = CKSoftwareMap.shared()) {
        self.softwareMap = softwareMap
    }

    /// Finds an app using a bundle identifier.
    ///
    /// - Parameter bundleId: Bundle identifier of app.
    /// - Returns: Software Product of app if found; nil otherwise.
    func installedApp(forBundleId bundleId: String) -> SoftwareProduct? {
        softwareMap.product(for: bundleId)
    }

    /// Uninstalls an app.
    ///
    /// - Parameter app: App to be removed.
    /// - Throws: Error if there is a problem.
    func uninstallApp(app: SoftwareProduct) throws {
        if NSUserName() != "root" {
            throw MASError.macOSUserMustBeRoot
        }

        let appUrl = URL(fileURLWithPath: app.bundlePath)
        do {
            // Move item to trash
            var trashUrl: NSURL?
            try FileManager().trashItem(at: appUrl, resultingItemURL: &trashUrl)
            if let path = trashUrl?.path {
                printInfo("App moved to trash: \(path)")
            }
        } catch {
            printError("Unable to move app to trash.")
            throw MASError.uninstallFailed
        }
    }
}
