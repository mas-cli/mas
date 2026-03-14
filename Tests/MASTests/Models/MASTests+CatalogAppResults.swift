//
// MASTests+CatalogAppResults.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func `parses catalog app results from BBEdit JSON`() {
		let actual = consequencesOf(try decode(CatalogAppResults.self, fromResource: "bbedit").resultCount)
		let expected = Consequences(1)
		#expect(actual == expected)
	}

	@Test
	func `parses catalog app results from Things JSON`() {
		let actual = consequencesOf(try decode(CatalogAppResults.self, fromResource: "things").resultCount)
		let expected = Consequences(12)
		#expect(actual == expected)
	}
}
