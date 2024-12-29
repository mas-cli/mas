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
        if #available(macOS 10.15, *) {
            if let storefront = SKPaymentQueue.default().storefront {
                return findISORegion(forAlpha3Code: storefront.countryCode)
            }
        }

        guard let alpha2 = Locale.autoupdatingCurrent.regionCode else {
            return nil
        }

        return findISORegion(forAlpha2Code: alpha2)
    }
}
