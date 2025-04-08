//
//  SearchResult.swift
//  mas
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

struct SearchResult: Decodable {
    var currentVersionReleaseDate = ""
    var fileSizeBytes = "0"
    var formattedPrice = "0" as String?
    var minimumOsVersion = ""
    var sellerName = ""
    var sellerUrl = "" as String?
    var trackId = 0 as AppID
    var trackName = ""
    var trackViewUrl = ""
    var version = ""
}

extension SearchResult {
    var displayPrice: String {
        formattedPrice ?? "?"
    }
}

extension SearchResult: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(trackId)
    }
}
