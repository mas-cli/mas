//
//  AppID.swift
//  mas
//
//  Created by Ross Goldberg on 2024-10-29.
//  Copyright © 2024 mas-cli. All rights reserved.
//

import Foundation

typealias AppID = UInt64

extension AppID {
    var unknownMessage: String {
        "Unknown app ID \(self)"
    }
}

// swiftlint:disable:next legacy_objc_type
extension NSNumber {
    var appIDValue: AppID {
        uint64Value
    }
}
