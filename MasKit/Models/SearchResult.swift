//
//  SearchResult.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

public struct SearchResult: Decodable {
    public var bundleId: String
    public var currentVersionReleaseDate: String
    public var fileSizeBytes: String?
    public var formattedPrice: String?
    public var minimumOsVersion: String
    public var price: Double?
    public var sellerName: String
    public var sellerUrl: String?
    public var trackId: Int
    public var trackCensoredName: String
    public var trackName: String
    public var trackViewUrl: String
    public var version: String

    init(bundleId: String = "",
         currentVersionReleaseDate: String = "",
         fileSizeBytes: String = "0",
         formattedPrice: String = "Free",
         minimumOsVersion: String = "",
         price: Double = 0.0,
         sellerName: String = "",
         sellerUrl: String = "",
         trackId: Int = 0,
         trackCensoredName: String = "",
         trackName: String = "",
         trackViewUrl: String = "",
         version: String = "") {
        self.bundleId = bundleId
        self.currentVersionReleaseDate = currentVersionReleaseDate
        self.fileSizeBytes = fileSizeBytes
        self.formattedPrice = formattedPrice
        self.minimumOsVersion = minimumOsVersion
        self.price = price
        self.sellerName = sellerName
        self.sellerUrl = sellerUrl
        self.trackId = trackId
        self.trackCensoredName = trackCensoredName
        self.trackName = trackName
        self.trackViewUrl = trackViewUrl
        self.version = version
    }
}
