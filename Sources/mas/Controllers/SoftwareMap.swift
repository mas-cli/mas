//
//  SoftwareMap.swift
//  mas
//
//  Created by Ben Chatelain on 3/1/20.
//  Copyright © 2020 mas-cli. All rights reserved.
//

/// Somewhat analogous to CKSoftwareMap.
protocol SoftwareMap {
    func allSoftwareProducts() async -> [SoftwareProduct]
}
