//
//  SearchResult.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

public struct SearchResult: Decodable {
    public var bundleId: String
    public var price: Double
    public var sellerName: String
    public var sellerUrl: String
    public var trackId: Int
    public var trackName: String
    public var trackViewUrl: String
    public var version: String
}
