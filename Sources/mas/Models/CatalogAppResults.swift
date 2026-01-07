//
// CatalogAppResults.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct CatalogAppResults: Decodable, Sendable { // swiftlint:disable:next unused_declaration
	let resultCount: Int // periphery:ignore
	let results: [CatalogApp]
}
