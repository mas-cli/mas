//
//  AppLibrary.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Utility for managing installed apps.
public protocol AppLibrary {
    /// Finds an app by ID from the set of installed apps
    ///
    /// - Parameter appId: MAS ID for app.
    /// - Returns: Software Product of app if found; nil otherwise.
    func installedApp(appId: UInt64) -> SoftwareProduct?

    /// Uninstalls an app.
    ///
    /// - Parameter app: App to be removed.
    /// - Throws: Error if there is a problem.
    func uninstallApp(app: SoftwareProduct) throws
}
