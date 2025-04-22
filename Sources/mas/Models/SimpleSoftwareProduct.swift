//
//  SimpleSoftwareProduct.swift
//  mas
//
//  Created by Ross Goldberg on 2025-04-09.
//  Copyright © 2025 mas-cli. All rights reserved.
//

struct SimpleSoftwareProduct: SoftwareProduct {
    let appID: AppID
    let appName: String
    let bundleIdentifier: String
    let bundlePath: String
    let bundleVersion: String
}
