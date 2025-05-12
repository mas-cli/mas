//
// SearchResultList.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct SearchResultList: Decodable {
	var resultCount: Int // swiftlint:disable:this unused_declaration
	var results: [SearchResult]
}
