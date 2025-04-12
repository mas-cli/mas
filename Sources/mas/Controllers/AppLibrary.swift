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

    /// Uninstalls all apps located at any of the elements of `appPaths`.
    ///
    /// - Parameter appPaths: Paths to apps to be uninstalled.
    /// - Throws: An `Error` if any problem occurs.
    func uninstallApps(atPaths appPaths: [String]) throws
}

/// Common logic
extension AppLibrary {
    /// Finds all installed instances of apps whose app ID is `appID`.
    ///
    /// - Parameter appID: app ID for app(s).
    /// - Returns: [SoftwareProduct] of matching apps.
    func installedApps(withAppID appID: AppID) -> [SoftwareProduct] {
        // swiftlint:disable:next legacy_objc_type
        let appID = NSNumber(value: appID)
        return installedApps.filter { $0.itemIdentifier == appID }
    }

    /// Finds all installed instances of apps whose name is `appName`.
    ///
    /// - Parameter appName: Full name of app(s).
    /// - Returns: [SoftwareProduct] of matching apps.
    func installedApps(named appName: String) -> [SoftwareProduct] {
        installedApps.filter { $0.appName == appName }
    }
}
