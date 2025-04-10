//
//  SimpleSoftwareProduct.swift
//  mas
//
//  Created by Ross Goldberg on 2025-04-09.
//  Copyright © 2025 mas-cli. All rights reserved.
//

import Foundation

struct SimpleSoftwareProduct: SoftwareProduct {
    var appName: String
    var bundleIdentifier: String
    var bundlePath: String
    var bundleVersion: String
    // swiftlint:disable:next legacy_objc_type
    var itemIdentifier: NSNumber
}
