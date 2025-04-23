//
//  AppLibrary.swift
//  mas
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Utility for managing installed apps.
protocol AppLibrary {
    /// Entire set of installed apps.
    var installedApps: [InstalledApp] { get }

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
    /// - Returns: [InstalledApp] of matching apps.
    func installedApps(withAppID appID: AppID) -> [InstalledApp] {
        installedApps.filter { $0.id == appID }
    }

    /// Finds all installed instances of apps whose name is `appName`.
    ///
    /// - Parameter appName: Full name of app(s).
    /// - Returns: [InstalledApp] of matching apps.
    func installedApps(named appName: String) -> [InstalledApp] {
        installedApps.filter { $0.name == appName }
    }
}
