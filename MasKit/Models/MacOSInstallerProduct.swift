//
//  MacOSInstallerProduct.swift
//  MasKit
//
//  Created by Ben Chatelain on 2/5/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

public struct MacOSInstallerProduct: SoftwareProduct {
    public var accountIdentifier: String
    public var accountOpaqueDSID: String
    public var appName: String
    public var bundleIdentifier: String
    public var bundlePath: String
    public var bundleVersion: String
    public var description: String
    public var expectedBundleVersion: String?
    public var expectedStoreVersion: NSNumber?
    public var mdItemRef: NSValue?
    public var installed: Bool
    public var isLegacyApp: Bool
    public var isMachineLicensed: Bool
    public var itemIdentifier: NSNumber
    public var purchaseDate: Date?
    public var storeFrontIdentifier: NSNumber?

    private let macOS: MacOS

    /// Creates a macOS Installer product from a CKSoftwareProduct.
    ///
    /// - Parameter product: Software product to copy.
    init(fromProduct product: SoftwareProduct) {
        guard let macOS = MacOS.os(fromBundleIdentifier: product.bundleIdentifier)
        else {
            fatalError("Unknown macOS Installer \(product.appName) \(product.bundleIdentifier) \(product.bundlePath)")
        }

        self.macOS = macOS

        itemIdentifier = product.itemIdentifier == 0
            ? NSNumber(value: macOS.identifier)
            : product.itemIdentifier

        accountIdentifier = product.accountIdentifier
        accountOpaqueDSID = product.accountOpaqueDSID
        appName = product.appName
        bundleIdentifier = product.bundleIdentifier
        bundlePath = product.bundlePath
        bundleVersion = product.bundleVersion
        description = product.description
        expectedBundleVersion = product.expectedBundleVersion
        expectedStoreVersion = product.expectedStoreVersion
        mdItemRef = product.mdItemRef
        installed = product.installed
        isLegacyApp = product.isLegacyApp
        isMachineLicensed = product.isMachineLicensed
        purchaseDate = product.purchaseDate
        storeFrontIdentifier = product.storeFrontIdentifier
    }
}
