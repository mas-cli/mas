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

    /// Designated initializer
    public init() {}

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
        let fileManager = FileManager()
        let appUrl = URL(fileURLWithPath: app.bundlePath)

        do {
            try fileManager.trashItem(at: appUrl, resultingItemURL: nil)
        } catch {
            printError("Unable to move app to trash.")
            throw MASError.uninstallFailed
        }
    }
}
