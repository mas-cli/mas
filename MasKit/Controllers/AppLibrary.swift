//
//  AppLibrary.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Utility for managing installed apps.
public protocol AppLibrary {
    /// Entire set of installed apps.
    var installedApps: [SoftwareProduct] { get }

    /// Map of app name to ID.
    var appIdsByName: [String: UInt64] { get }

    /// Finds an app by ID.
    ///
    /// - Parameter forId: MAS ID for app.
    /// - Returns: Software Product of app if found; nil otherwise.
    func installedApp(forId: UInt64) -> SoftwareProduct?

    /// Finds an app by it's bundle identifier.
    ///
    /// - Parameter forBundleId: Bundle identifier of app.
    /// - Returns: Software Product of app if found; nil otherwise.
    func installedApp(forBundleId: String) -> SoftwareProduct?

    /// Finds an app by name.
    ///
    /// - Parameter named: Name of app.
    /// - Returns: Software Product of app if found; nil otherwise.
    func installedApp(named: String) -> SoftwareProduct?

    /// Uninstalls an app.
    ///
    /// - Parameter app: App to be removed.
    /// - Throws: Error if there is a problem.
    func uninstallApp(app: SoftwareProduct) throws
}

/// Common logic
extension AppLibrary {
    /// Map of app name to ID.
    public var appIdsByName: [String: UInt64] {
        var destMap = [String: UInt64]()
        for product in installedApps {
            destMap[product.appName] = product.itemIdentifier?.uint64Value
        }
        return destMap
    }

    /// Finds an app by name.
    ///
    /// - Parameter id: MAS ID for app.
    /// - Returns: Software Product of app if found; nil otherwise.
    public func installedApp(forId identifier: UInt64) -> SoftwareProduct? {
        let appId = NSNumber(value: identifier)
        return installedApps.first { $0.itemIdentifier == appId }
    }

    /// Finds an app by name.
    ///
    /// - Parameter appName: Full title of an app.
    /// - Returns: Software Product of app if found; nil otherwise.
    public func installedApp(named appName: String) -> SoftwareProduct? {
        return installedApps.first { $0.appName == appName }
    }
}
