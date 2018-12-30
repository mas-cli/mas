//
//  SearchResult.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

struct SearchResult: Decodable {
    var bundleId: String
    var price: Double
    var sellerName: String
    var sellerUrl: String
    var trackId: Int
    var trackName: String
    var trackViewUrl: String
    var version: String
}
