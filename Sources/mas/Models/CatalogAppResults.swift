//
// CatalogAppResults.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

struct CatalogAppResults: Decodable, Sendable {
	// periphery:ignore
	let resultCount: Int // swiftlint:disable:this unused_declaration
	let results: [CatalogApp]
}
