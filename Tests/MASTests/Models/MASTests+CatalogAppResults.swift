//
// MASTests+CatalogAppResults.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	func parsesCatalogAppResultsFromBBEditJSON() {
		let actual =
			consequencesOf(try JSONDecoder().decode(CatalogAppResults.self, from: Data(fromResource: "bbedit")).resultCount)
		let expected = Consequences(1)
		#expect(actual == expected)
	}

	@Test
	func parsesCatalogAppResultsFromThingsJSON() {
		let actual =
			consequencesOf(try JSONDecoder().decode(CatalogAppResults.self, from: Data(fromResource: "things")).resultCount)
		let expected = Consequences(50)
		#expect(actual == expected)
	}
}
