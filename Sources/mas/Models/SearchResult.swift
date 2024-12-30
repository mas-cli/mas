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
    var formattedPrice: String? = "0"
    var minimumOsVersion = ""
    var sellerName = ""
    var sellerUrl: String? = ""
    var trackId: AppID = 0
    var trackName = ""
    var trackViewUrl = ""
    var version = ""

    var displayPrice: String {
        formattedPrice ?? "Unknown"
    }
}
