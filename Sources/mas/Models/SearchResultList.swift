//
// SearchResultList.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct SearchResultList: Decodable {
	let resultCount: Int // swiftlint:disable:this unused_declaration
	let results: [SearchResult]
}
