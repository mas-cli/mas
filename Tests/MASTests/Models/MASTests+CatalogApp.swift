//
// MASTests+CatalogApp.swift
// mas
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import Foundation
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func parsesCatalogAppFromThingsThatGoBumpJSON() {
		let actual = consequencesOf(
			try JSONDecoder().decode(CatalogApp.self, from: Data(fromResource: "things-lookup")).adamID
		)
		let expected = Consequences(1_472_954_003 as ADAMID)
		#expect(actual == expected)
	}
}
