//
// CatalogAppResults.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct CatalogAppResults: Decodable { // swiftlint:disable:next unused_declaration
	let resultCount: Int // periphery:ignore
	let results: [CatalogApp]
}
