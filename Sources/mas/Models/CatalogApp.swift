//
// CatalogApp.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct CatalogApp {
	let adamID: ADAMID
	let appStorePageURLString: String
	// periphery:ignore
	let bundleID: String
	let fileSizeBytes: String
	let formattedPrice: String
	let minimumOSVersion: String
	let name: String
	let releaseDate: String
	let sellerName: String
	let sellerURLString: String?
	let version: String

	init(
		adamID: ADAMID = 0,
		appStorePageURLString: String = "",
		bundleID: String = "",
		fileSizeBytes: String = "0",
		formattedPrice: String? = "0",
		minimumOSVersion: String = "",
		name: String = "",
		releaseDate: String = "",
		sellerName: String = "",
		sellerURLString: String? = nil,
		version: String = ""
	) { // periphery:ignore
		self.adamID = adamID
		self.appStorePageURLString = appStorePageURLString
		self.bundleID = bundleID
		self.fileSizeBytes = fileSizeBytes
		self.formattedPrice = formattedPrice ?? "?"
		self.minimumOSVersion = minimumOSVersion
		self.name = name
		self.releaseDate = releaseDate
		self.sellerName = sellerName
		self.sellerURLString = sellerURLString
		self.version = version
	}
}

extension CatalogApp: Decodable {
	enum CodingKeys: String, CodingKey {
		case adamID = "trackId"
		case appStorePageURLString = "trackViewUrl"
		case bundleID = "bundleId"
		case fileSizeBytes
		case formattedPrice
		case minimumOSVersion = "minimumOsVersion"
		case name = "trackName"
		case releaseDate = "currentVersionReleaseDate"
		case sellerName
		case sellerURLString = "sellerUrl"
		case version
	}
}
