//
//  ISORegion.swift
//  mas
//
//  Created by Ross Goldberg on 2024-12-29.
//  Copyright (c) 2024 mas-cli. All rights reserved.
//

import IsoCountryCodes
import StoreKit

// periphery:ignore
protocol ISORegion {
    var name: String { get }
    var numeric: String { get }
    var alpha2: String { get }
    var alpha3: String { get }
    var calling: String { get }
    var currency: String { get }
    var continent: String { get }
    var flag: String? { get }
    var fractionDigits: Int { get }
}

extension IsoCountryInfo: ISORegion {}

var isoRegion: ISORegion? {
    if let storefront = SKPaymentQueue.default().storefront {
        findISORegion(forAlpha3Code: storefront.countryCode)
    } else if let alpha2 = Locale.autoupdatingCurrent.regionCode {
        findISORegion(forAlpha2Code: alpha2)
    } else {
        nil
    }
}

func findISORegion(forAlpha2Code alpha2Code: String) -> ISORegion? {
    let alpha2Code = alpha2Code.uppercased()
    return IsoCountries.allCountries.first { $0.alpha2 == alpha2Code }
}

func findISORegion(forAlpha3Code alpha3Code: String) -> ISORegion? {
    let alpha3Code = alpha3Code.uppercased()
    return IsoCountries.allCountries.first { $0.alpha3 == alpha3Code }
}
