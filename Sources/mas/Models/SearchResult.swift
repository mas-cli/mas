//
// SearchResult.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct SearchResult: Equatable {
	let adamID: ADAMID
	let appStorePageURL: String
	// periphery:ignore
	let bundleID: String
	let fileSizeBytes: String
	let formattedPrice: String
	let minimumOSVersion: String
	let name: String
	let releaseDate: String
	let sellerName: String
	let sellerURL: String?
	let version: String

	init(
		adamID: ADAMID = 0,
		appStorePageURL: String = "",
		bundleID: String = "",
		fileSizeBytes: String = "0",
		formattedPrice: String? = "0",
		minimumOSVersion: String = "",
		name: String = "",
		releaseDate: String = "",
		sellerName: String = "",
		sellerURL: String? = nil,
		version: String = ""
	) { // periphery:ignore
		self.adamID = adamID
		self.appStorePageURL = appStorePageURL
		self.bundleID = bundleID
		self.fileSizeBytes = fileSizeBytes
		self.formattedPrice = formattedPrice ?? "?"
		self.minimumOSVersion = minimumOSVersion
		self.name = name
		self.releaseDate = releaseDate
		self.sellerName = sellerName
		self.sellerURL = sellerURL
		self.version = version
	}
}

extension SearchResult: Decodable {
	enum CodingKeys: String, CodingKey {
		case adamID = "trackId"
		case appStorePageURL = "trackViewUrl"
		case bundleID = "bundleId"
		case fileSizeBytes
		case formattedPrice
		case minimumOSVersion = "minimumOsVersion"
		case name = "trackName"
		case releaseDate = "currentVersionReleaseDate"
		case sellerName
		case sellerURL = "sellerUrl"
		case version
	}
}
