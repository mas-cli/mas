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
    public var itemIdentifier: NSNumber?
//    public var purchaseDate: Date
    public var storeFrontIdentifier: NSNumber

    private let macOS: MacOS

    /// Creates a macOS Installer product from a CKSoftwareProduct.
    ///
    /// - Parameter product: Software product to copy.
    init(fromProduct product: SoftwareProduct) {
        guard let macOS = MacOS.os(fromAppName: product.appName)
        else { fatalError("Unknown macOS Installer \(product.appName)") }

        self.macOS = macOS

        itemIdentifier = product.itemIdentifier ?? NSNumber(value: macOS.identifier)

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
//        purchaseDate = product.purchaseDate
        storeFrontIdentifier = product.storeFrontIdentifier
    }

    /// Look up OS based on store display name.
    ///
    /// - Parameter appName: <#appName description#>
    /// - Returns: <#return value description#>
    private func osVersionFromAppName(_ appName: String) -> MacOS? {
        let prefixes = ["Install macOS", "Install OS X"]
        let startIndex = prefixes.compactMap { (prefix) -> String.Index? in
            if appName.starts(with: prefix) {
                return appName.index(appName.startIndex, offsetBy: prefix.count)
            }
            return nil
        }.first

        let name = appName[startIndex!...]

        for macos in MacOS.allCases where macos.name == name {
            return macos
        }

        return nil
    }
}
