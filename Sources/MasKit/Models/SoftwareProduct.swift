//
//  SoftwareProduct.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import Version

/// Protocol describing the members of CKSoftwareProduct used throughout MasKit.
protocol SoftwareProduct {
    var appName: String { get }
    var bundleIdentifier: String { get set }
    var bundlePath: String { get set }
    var bundleVersion: String { get set }
    var itemIdentifier: NSNumber { get set }
}

// MARK: - Equatable
extension SoftwareProduct {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.appName == rhs.appName
            && lhs.bundleIdentifier == rhs.bundleIdentifier
            && lhs.bundlePath == rhs.bundlePath
            && lhs.bundleVersion == rhs.bundleVersion
            && lhs.itemIdentifier == rhs.itemIdentifier
    }

    /// Returns bundleIdentifier if appName is empty string.
    var appNameOrBundleIdentifier: String {
        appName == "" ? bundleIdentifier : appName
    }

    func isOutdatedWhenComparedTo(_ storeApp: SearchResult) -> Bool {
        // The App Store does not enforce semantic versioning, but we assume most apps follow versioning
        // schemes that increase numerically over time.
        guard let semanticBundleVersion = Version(tolerant: bundleVersion),
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
