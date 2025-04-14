//
//  SoftwareProduct.swift
//  mas
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import Version

/// Protocol describing the members of CKSoftwareProduct used throughout mas.
protocol SoftwareProduct {
    var appName: String { get }
    // periphery:ignore
    var bundleIdentifier: String { get set }
    var bundlePath: String { get set }
    var bundleVersion: String { get set }
    // swiftlint:disable:next legacy_objc_type
    var itemIdentifier: NSNumber { get set }
}

extension SoftwareProduct {
    var displayName: String {
        appName
    }

    /// Determines whether the app is considered outdated.
    ///
    /// Updates that require a higher OS version are excluded.
    ///
    /// - Parameter storeApp: App from search result.
    /// - Returns: true if the app is outdated; false otherwise.
    func isOutdated(comparedTo storeApp: SearchResult) -> Bool {
        // If storeApp requires a version of macOS newer than the running version, do not consider self outdated.
        if let osVersion = Version(tolerant: storeApp.minimumOsVersion) {
            let requiredVersion = OperatingSystemVersion(
                majorVersion: osVersion.major,
                minorVersion: osVersion.minor,
                patchVersion: osVersion.patch
            )
            guard ProcessInfo.processInfo.isOperatingSystemAtLeast(requiredVersion) else {
                return false
            }
        }

        // The App Store does not enforce semantic versioning, but we assume most apps follow versioning
        // schemes that increase numerically over time.
        guard
            let semanticBundleVersion = Version(tolerant: bundleVersion),
            let semanticAppStoreVersion = Version(tolerant: storeApp.version)
        else {
            // If a version string can't be parsed as a Semantic Version, our best effort is to check for
            // equality. The only version that matters is the one in the App Store.
            // https://semver.org
            return bundleVersion != storeApp.version
        }

        return semanticBundleVersion < semanticAppStoreVersion
    }
}
