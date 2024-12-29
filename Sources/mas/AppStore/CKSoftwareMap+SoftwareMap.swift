//
//  CKSoftwareMap+SoftwareMap.swift
//  mas
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import CommerceKit

extension CKSoftwareMap: SoftwareMap {
    func allSoftwareProducts() -> [SoftwareProduct] {
        allProducts() ?? []
    }
}
