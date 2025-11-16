//
// MASTests+SearchResultList.swift
// mas
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import Foundation
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	func parsesSearchResultListFromBBEditJSON() {
		let actual =
			consequencesOf(try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "bbedit")).resultCount)
		let expected = Consequences(1)
		#expect(actual == expected)
	}

	@Test
	func parsesSearchResultListFromThingsJSON() {
		let actual =
			consequencesOf(try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "things")).resultCount)
		let expected = Consequences(50)
		#expect(actual == expected)
	}
}
