//
//  Storefront.swift
//  mas
//
//  Created by Ross Goldberg on 2024-12-29.
//  Copyright (c) 2024 mas-cli. All rights reserved.
//

import StoreKit

enum Storefront {
    static var isoRegion: ISORegion? {
        if let storefront = SKPaymentQueue.default().storefront {
            findISORegion(forAlpha3Code: storefront.countryCode)
        } else if let alpha2 = Locale.autoupdatingCurrent.regionCode {
            findISORegion(forAlpha2Code: alpha2)
        } else {
            nil
        }
    }
}
