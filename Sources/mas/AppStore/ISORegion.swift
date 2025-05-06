//
// ISORegion.swift
// mas
//
// Created by Ross Goldberg on 2024-12-29.
// Copyright © 2024 mas-cli. All rights reserved.
//

private import IsoCountryCodes
private import StoreKit

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
	get async {
		if let alpha3 = await alpha3 {
			findISORegion(forAlpha3Code: alpha3)
		} else if let alpha2 {
			findISORegion(forAlpha2Code: alpha2)
		} else {
			nil
		}
	}
}

private var alpha3: String? {
	get async {
		if #available(macOS 12, *) {
			await Storefront.current?.countryCode
		} else {
			SKPaymentQueue.default().storefront?.countryCode
		}
	}
}

private var alpha2: String? {
	if #available(macOS 13, *) {
		Locale.autoupdatingCurrent.region?.identifier
	} else {
		Locale.autoupdatingCurrent.regionCode
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
