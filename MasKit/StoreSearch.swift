//
//  StoreSearch.swift
//  MasKit
//
//  Created by Ben Chatelain on 12/29/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

/// Protocol for searching the MAS catalog.
public protocol StoreSearch {
    func lookupURLString(forApp: String) -> String?
    func lookup(app appId: String) throws -> SearchResult?
}
