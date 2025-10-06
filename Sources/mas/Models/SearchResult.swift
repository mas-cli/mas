//
// SearchResult.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct SearchResult: AppIdentifying {
	let adamID: ADAMID
	let appStoreURL: String
	let bundleID: String
	let fileSizeBytes: String
	let formattedPrice: String
	let minimumOSVersion: String
	let name: String
	let releaseDate: String
	let vendorName: String
	let vendorURL: String?
	let version: String

	init(
		adamID: ADAMID = 0,
		appStoreURL: String = "",
		bundleID: String = "",
		fileSizeBytes: String = "0",
		formattedPrice: String? = "0",
		minimumOSVersion: String = "",
		name: String = "",
		releaseDate: String = "",
		vendorName: String = "",
		vendorURL: String? = nil,
		version: String = ""
	) {
		self.adamID = adamID
		self.appStoreURL = appStoreURL
		self.bundleID = bundleID
		self.fileSizeBytes = fileSizeBytes
		self.formattedPrice = formattedPrice ?? "?"
		self.minimumOSVersion = minimumOSVersion
		self.name = name
		self.releaseDate = releaseDate
		self.vendorName = vendorName
		self.vendorURL = vendorURL
		self.version = version
	}
}

extension SearchResult: Decodable {
	enum CodingKeys: String, CodingKey {
		case adamID = "trackId"
		case appStoreURL = "trackViewUrl"
		case bundleID = "bundleId"
		case fileSizeBytes
		case formattedPrice
		case minimumOSVersion = "minimumOsVersion"
		case name = "trackName"
		case releaseDate = "currentVersionReleaseDate"
		case vendorName = "sellerName"
		case vendorURL = "sellerUrl"
		case version
	}
}

extension SearchResult: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(adamID)
	}
}
