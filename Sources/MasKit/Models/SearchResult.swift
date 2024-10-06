//
//  SearchResult.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

struct SearchResult: Decodable {
    var bundleId: String
    var currentVersionReleaseDate: String
    var fileSizeBytes: String?
    var minimumOsVersion: String
    var price: Double?
    var sellerName: String
    var sellerUrl: String?
    var trackId: Int
    var trackName: String
    var trackViewUrl: String
    var version: String

    init(
        bundleId: String = "",
        currentVersionReleaseDate: String = "",
        fileSizeBytes: String = "0",
        minimumOsVersion: String = "",
        price: Double = 0.0,
        sellerName: String = "",
        sellerUrl: String = "",
        trackId: Int = 0,
        trackName: String = "",
        trackViewUrl: String = "",
        version: String = ""
    ) {
        self.bundleId = bundleId
        self.currentVersionReleaseDate = currentVersionReleaseDate
        self.fileSizeBytes = fileSizeBytes
        self.minimumOsVersion = minimumOsVersion
        self.price = price
        self.sellerName = sellerName
        self.sellerUrl = sellerUrl
        self.trackId = trackId
        self.trackName = trackName
        self.trackViewUrl = trackViewUrl
        self.version = version
    }
}
