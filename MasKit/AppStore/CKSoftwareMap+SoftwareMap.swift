//
//  CKSoftwareMap+SoftwareMap.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import CommerceKit

// MARK: - SoftwareProduct
extension CKSoftwareMap: SoftwareMap {
    func allSoftwareProducts() -> [SoftwareProduct] {
        return allProducts() ?? []
    }

    func product(for bundleIdentifier: String) -> SoftwareProduct? {
        return product(forBundleIdentifier: bundleIdentifier)
    }
}
