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
}
