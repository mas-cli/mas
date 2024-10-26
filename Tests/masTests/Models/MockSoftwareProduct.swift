//
//  MockSoftwareProduct.swift
//  masTests
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation

@testable import mas

struct MockSoftwareProduct: SoftwareProduct {
    var appName: String
    var bundleIdentifier: String
    var bundlePath: String
    var bundleVersion: String
    var itemIdentifier: NSNumber
}
