//
//  MockSoftwareProduct.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit

struct MockSoftwareProduct: SoftwareProduct {
    var appName: String
    var bundlePath: String
    var bundleVersion: String
    var itemIdentifier: NSNumber
}
