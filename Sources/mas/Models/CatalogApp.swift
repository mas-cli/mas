//
// CatalogApp.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct CatalogApp {
	let adamID: ADAMID
	let appStorePageURLString: String
	let bundleID: String
	let fileSizeBytes: String
	let formattedPrice: String?
	let minimumOSVersion: String
	let name: String
	let releaseDate: String
	let sellerName: String
	let sellerURLString: String?
	let supportedDevices: [String]? // swiftlint:disable:this discouraged_optional_collection
	let version: String

	var displayPrice: String {
		formattedPrice ?? "?"
	}

	init(
		adamID: ADAMID = 0,
		appStorePageURLString: String = "",
		bundleID: String = "",
		fileSizeBytes: String = "?",
		formattedPrice: String? = "?",
		minimumOSVersion: String = "",
		name: String = "",
		releaseDate: String = "",
		sellerName: String = "",
		sellerURLString: String? = nil,
		supportedDevices: [String]? = nil, // swiftlint:disable:this discouraged_optional_collection
		version: String = "",
	) {
		self.adamID = adamID
		self.appStorePageURLString = appStorePageURLString
		self.bundleID = bundleID
		self.fileSizeBytes = fileSizeBytes
		self.formattedPrice = formattedPrice
		self.minimumOSVersion = minimumOSVersion
		self.name = name
		self.releaseDate = releaseDate
		self.sellerName = sellerName
		self.sellerURLString = sellerURLString
		self.supportedDevices = supportedDevices
		self.version = version
	}

	func with(minimumOSVersion: String) -> Self {
		.init(
			adamID: adamID,
			appStorePageURLString: appStorePageURLString,
			bundleID: bundleID,
			fileSizeBytes: fileSizeBytes,
			formattedPrice: formattedPrice,
			minimumOSVersion: minimumOSVersion,
			name: name,
			releaseDate: releaseDate,
			sellerName: sellerName,
			sellerURLString: sellerURLString,
			supportedDevices: supportedDevices,
			version: version,
		)
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
		case supportedDevices
		case version
	}
}
