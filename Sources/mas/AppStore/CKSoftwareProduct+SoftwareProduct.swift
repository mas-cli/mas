//
//  CKSoftwareProduct+SoftwareProduct.swift
//  mas
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import StoreFoundation

extension CKSoftwareProduct: SoftwareProduct, @retroactive @unchecked Sendable {
    var appID: AppID {
        get { itemIdentifier.appIDValue }
        // swiftlint:disable:next legacy_objc_type
        set { itemIdentifier = NSNumber(value: newValue) }
    }
}
