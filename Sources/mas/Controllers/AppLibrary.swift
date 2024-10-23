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

    /// Uninstalls an app.
    ///
    /// - Parameter app: App to be removed.
    /// - Throws: Error if there is a problem.
    func uninstallApp(app: SoftwareProduct) throws
}

/// Common logic
extension AppLibrary {
    /// Finds an app for appID.
    ///
    /// - Parameter appID: app ID for app.
    /// - Returns: SoftwareProduct of app if found; nil otherwise.
    func installedApp(withAppID appID: AppID) -> SoftwareProduct? {
        let appID = NSNumber(value: appID)
        return installedApps.first { $0.itemIdentifier == appID }
    }

    /// Finds an app by name.
    ///
    /// - Parameter appName: Full title of an app.
    /// - Returns: Software Product of app if found; nil otherwise.
    func installedApp(named appName: String) -> SoftwareProduct? {
        installedApps.first { $0.appName == appName }
    }
}
