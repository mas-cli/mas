//
//  SoftwareProduct.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation

/// Protocol describing the members of CKSoftwareProduct used throughout MasKit.
public protocol SoftwareProduct {
    /// Not used
    var accountIdentifier: String { get }
    /// Not used
    var accountOpaqueDSID: String { get }

    /// Display name of app. Empty string on 10.14.4 (see #226).
    var appName: String { get }

    /// System identifier for apps on macOS.
    var bundleIdentifier: String { get set }

    /// Path to .app bundle.
    var bundlePath: String { get set }

    /// Version of app
    var bundleVersion: String { get set }

    /// Summary of type for debugging.
    var description: String { get }

    /// Not used
    var expectedBundleVersion: String? { get set }
    /// Not used
    var expectedStoreVersion: NSNumber? { get set }
    /// Not used
    var mdItemRef: NSValue? { get set }
    /// Not used
    var installed: Bool { get set }
    /// Not used
    var isLegacyApp: Bool { get set }
    /// Not used
    var isMachineLicensed: Bool { get set }

    /// App Store identifier for apps. zero (or nil?) for macOS installers.
    var itemIdentifier: NSNumber { get set }

    /// Not populated for macOS installers.
    var purchaseDate: Date? { get set }

    /// Not used
    var storeFrontIdentifier: NSNumber? { get set }
}

// MARK: - Equatable
extension SoftwareProduct {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.appName == rhs.appName
            && lhs.bundleIdentifier == rhs.bundleIdentifier
            && lhs.bundlePath == rhs.bundlePath
            && lhs.bundleVersion == rhs.bundleVersion
            && lhs.itemIdentifier == rhs.itemIdentifier
    }

    /// Determines whether this product is a macOS installer.
    var isMacosInstaller: Bool {
        return bundleIdentifier.starts(with: MacOS.bundleIdentifierBase)
    }
}
