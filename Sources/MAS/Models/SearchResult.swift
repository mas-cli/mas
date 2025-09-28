//
// SearchResult.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct SearchResult: Decodable {
	var bundleId = "" // swiftlint:disable:this unused_declaration
	var currentVersionReleaseDate = ""
	var fileSizeBytes = "0"
	var formattedPrice = "0" as String?
	var minimumOsVersion = ""
	var sellerName = ""
	var sellerUrl = "" as String?
	var trackId = 0 as ADAMID
	var trackName = ""
	var trackViewUrl = ""
	var version = ""
}

extension SearchResult: AppIdentifying {
	var adamID: ADAMID { trackId }
	var bundleID: String { bundleId }
	var outputPrice: String { formattedPrice ?? "?" }
}

extension SearchResult: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(trackId)
	}
}
