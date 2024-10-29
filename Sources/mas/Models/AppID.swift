//
//  AppID.swift
//  mas
//
//  Created by Ross Goldberg on 2024-10-29.
//  Copyright © 2024 mas-cli. All rights reserved.
//

import Foundation

typealias AppID = UInt64

extension NSNumber {
    var appIDValue: AppID {
        uint64Value
    }
}
