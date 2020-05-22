//
//  SoftwareProductMock.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit

struct SoftwareProductMock: SoftwareProduct {
    var appName: String
    var bundleIdentifier: String
    var bundlePath: String
    var bundleVersion: String
    var itemIdentifier: NSNumber

    // Fields not currently in use
    var accountIdentifier: String
    var accountOpaqueDSID: String
    var description: String
    var expectedBundleVersion: String?
    var expectedStoreVersion: NSNumber?
    var mdItemRef: NSValue?
    var installed: Bool
    var isLegacyApp: Bool
    var isMachineLicensed: Bool
    var purchaseDate: Date?
    var storeFrontIdentifier: NSNumber?

    init(
        appName: String = "",
        bundleIdentifier: String = "",
        bundlePath: String = "",
        bundleVersion: String = "",
        itemIdentifier: NSNumber = 0,

        accountIdentifier: String = "",
        accountOpaqueDSID: String = "",
        description: String = "",
        expectedBundleVersion: String? = nil,
        expectedStoreVersion: NSNumber? = nil,
        mdItemRef: NSValue? = nil,
        installed: Bool = false,
        isLegacyApp: Bool = false,
        isMachineLicensed: Bool = false,
        purchaseDate: Date = Date(),
        storeFrontIdentifier: NSNumber = 0
    ) {
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
        self.bundlePath = bundlePath
        self.bundleVersion = bundleVersion
        self.itemIdentifier = itemIdentifier

        self.accountIdentifier = accountIdentifier
        self.accountOpaqueDSID = accountOpaqueDSID
        self.description = description
        self.expectedBundleVersion = expectedBundleVersion
        self.expectedStoreVersion = expectedStoreVersion
        self.mdItemRef = mdItemRef
        self.installed = installed
        self.isLegacyApp = isLegacyApp
        self.isMachineLicensed = isMachineLicensed
        self.purchaseDate = purchaseDate
        self.storeFrontIdentifier = storeFrontIdentifier
    }
}
