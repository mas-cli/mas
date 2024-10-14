//
//  CKSoftwareMap+SoftwareMap.swift
//  mas
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import CommerceKit

// MARK: - SoftwareProduct
extension CKSoftwareMap: SoftwareMap {
    func allSoftwareProducts() -> [SoftwareProduct] {
        allProducts() ?? []
    }

    func product(for bundleIdentifier: String) -> SoftwareProduct? {
        product(forBundleIdentifier: bundleIdentifier)
    }
}
