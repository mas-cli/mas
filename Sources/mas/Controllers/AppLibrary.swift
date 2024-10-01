//
//  AppLibrary.swift
//  mas
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation

/// Utility for managing installed apps.
protocol AppLibrary {
    /// Entire set of installed apps.
    var installedApps: [SoftwareProduct] { get }

    /// Finds an app by ID.
    ///
    /// - Parameter forId: MAS ID for app.
    /// - Returns: Software Product of app if found; nil otherwise.
    func installedApp(forId: UInt64) -> SoftwareProduct?

    /// Uninstalls an app.
    ///
    /// - Parameter app: App to be removed.
    /// - Throws: Error if there is a problem.
    func uninstallApp(app: SoftwareProduct) throws
}

/// Common logic
extension AppLibrary {
    /// Finds an app by ID.
    ///
    /// - Parameter forId: MAS ID for app.
    /// - Returns: Software Product of app if found; nil otherwise.
    func installedApp(forId identifier: UInt64) -> SoftwareProduct? {
        let appId = NSNumber(value: identifier)
        return installedApps.first { $0.itemIdentifier == appId }
    }

    /// Finds an app by name.
    ///
    /// - Parameter appName: Full title of an app.
    /// - Returns: Software Product of app if found; nil otherwise.
    func installedApp(named appName: String) -> SoftwareProduct? {
        installedApps.first { $0.appName == appName }
    }
}
