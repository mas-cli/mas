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
    private let softwareMap: SoftwareMap

    /// Array of installed software products.
    public lazy var installedApps: [SoftwareProduct] = {
        return softwareMap.allSoftwareProducts()
    }()

    /// Internal initializer for providing a mock software map.
    /// - Parameter softwareMap: SoftwareMap to use
    init(softwareMap: SoftwareMap = CKSoftwareMap.shared()) {
        self.softwareMap = softwareMap
    }

    /// Finds an app using a bundle identifier.
    ///
    /// - Parameter bundleId: Bundle identifier of app.
    /// - Returns: Software Product of app if found; nil otherwise.
    public func installedApp(forBundleId bundleId: String) -> SoftwareProduct? {
        return softwareMap.product(for: bundleId)
    }

    /// Uninstalls an app.
    ///
    /// - Parameter app: App to be removed.
    /// - Throws: Error if there is a problem.
    public func uninstallApp(app: SoftwareProduct) throws {
        if !userIsRoot() {
            printWarning("Apps installed from the Mac App Store require root permission to remove.")
        }

        let fileManager = FileManager()
        let appUrl = URL(fileURLWithPath: app.bundlePath)

        do {
            var trashUrl: NSURL?
            try withUnsafeMutablePointer(to: &trashUrl) { (mutablePointer: UnsafeMutablePointer<NSURL?>) in
                let pointer = AutoreleasingUnsafeMutablePointer<NSURL?>(mutablePointer)

                // Move item to trash
                try fileManager.trashItem(at: appUrl, resultingItemURL: pointer)

                if let url = pointer.pointee, let path = url.path {
                    printInfo("App moved to trash: \(path)")
                }
            }
        } catch {
            printError("Unable to move app to trash.")
            throw MASError.uninstallFailed
        }
    }

    /// Detects whether the current user is root.
    ///
    /// - Returns: true if the current user is root; false otherwise
    private func userIsRoot() -> Bool {
        return NSUserName() == "root"
    }
}
