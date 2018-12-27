//
//  SoftwareProduct.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Protocol describing the members of CKSoftwareProduct used throughout MasKit.
public protocol SoftwareProduct {
    var appName: String { get }
    var bundlePath: String { get set }
    var itemIdentifier: NSNumber { get set }
}
