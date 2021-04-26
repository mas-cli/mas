//
//  SoftwareMap.swift
//  MasKit
//
//  Created by Ben Chatelain on 3/1/20.
//  Copyright © 2020 mas-cli. All rights reserved.
//

/// Somewhat analygous to CKSoftwareMap
protocol SoftwareMap {
    func allSoftwareProducts() -> [SoftwareProduct]
    func product(for bundleIdentifier: String) -> SoftwareProduct?
}
