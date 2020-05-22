//
//  SoftwareProduct.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Protocol describing the members of CKSoftwareProduct used throughout MasKit.
public protocol SoftwareProduct {
    var accountIdentifier: String { get }
    var accountOpaqueDSID: String { get }
    var appName: String { get }
    var bundleIdentifier: String { get set }
    var bundlePath: String { get set }
    var bundleVersion: String { get set }
    var description: String { get }
    var expectedBundleVersion: String? { get set }
    var expectedStoreVersion: NSNumber? { get set }
    var mdItemRef: NSValue? { get set }
    var installed: Bool { get set }
    var isLegacyApp: Bool { get set }
    var isMachineLicensed: Bool { get set }
    var itemIdentifier: NSNumber? { get set }
    /// Not populated for macOS installers.
//    var purchaseDate: Date { get set }
    var storeFrontIdentifier: NSNumber { get set }
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
}
