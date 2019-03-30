//
//  SoftwareProductMock.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit

struct SoftwareProductMock: SoftwareProduct {
    var accountIdentifier: String
    var accountOpaqueDSID: String
    var bundleIdentifier: String
    var description: String
    var expectedBundleVersion: String?
    var expectedStoreVersion: NSNumber?
    var mdItemRef: NSValue?
    var installed: Bool
    var isLegacyApp: Bool
    var isMachineLicensed: Bool
    var purchaseDate: Date?
    var storeFrontIdentifier: NSNumber?

    var appName: String
    var bundleIdentifier: String
    var bundlePath: String
    var bundleVersion: String
    var itemIdentifier: NSNumber?

    init(
        accountIdentifier: String = "",
        accountOpaqueDSID: String = "",
        bundleIdentifier: String = "",
        description: String = "",
        expectedBundleVersion: String? = nil,
        expectedStoreVersion: NSNumber? = nil,
        mdItemRef: NSValue? = nil,
        installed: Bool = false,
        isLegacyApp: Bool = false,
        isMachineLicensed: Bool = false,
        purchaseDate: Date = Date(),
        storeFrontIdentifier: NSNumber = 0,

        appName: String = "",
        bundlePath: String = "",
        bundleVersion: String = "",
        itemIdentifier: NSNumber = 0
    ) {
        self.accountIdentifier = accountIdentifier
        self.accountOpaqueDSID = accountOpaqueDSID
        self.bundleIdentifier = bundleIdentifier
        self.description = description
        self.expectedBundleVersion = expectedBundleVersion
        self.expectedStoreVersion = expectedStoreVersion
        self.mdItemRef = mdItemRef
        self.installed = installed
        self.isLegacyApp = isLegacyApp
        self.isMachineLicensed = isMachineLicensed
        self.purchaseDate = purchaseDate
        self.storeFrontIdentifier = storeFrontIdentifier

        self.appName = appName
        self.bundlePath = bundlePath
        self.bundleVersion = bundleVersion
        self.itemIdentifier = itemIdentifier
    }
}
