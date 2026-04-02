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
	func `parses catalog app from things that go bump JSON`() {
		let actual = consequencesOf(
			try JSONDecoder().decode(CatalogApp.self, from: .init(fromResource: "things-lookup")).adamID,
		)
		let expected = Consequences(ADAMID(1_472_954_003))
		#expect(actual == expected)
	}
}
