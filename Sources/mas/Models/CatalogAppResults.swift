//
// CatalogAppResults.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

internal import JSONAST
private import JSONDecoding

struct CatalogAppResults: JSONDecodable {
	let resultCount: Int // periphery:ignore
	let results: [CatalogApp]

	init(json: JSON.Node) throws {
		guard case let .object(object) = json else {
			throw MASError.unparsableJSON(String(describing: json))
		}

		resultCount = try object["resultCount"]?.decode() ?? 0
		results = try object["results"]?.decode() ?? []
	}
}
