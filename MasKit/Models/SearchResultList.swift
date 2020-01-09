//
//  SearchResultList.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

public struct SearchResultList: Decodable {
    var resultCount: Int
    var results: [SearchResult]
}
