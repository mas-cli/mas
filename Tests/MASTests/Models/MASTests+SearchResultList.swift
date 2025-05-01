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
	static func parsesSearchResultListFromBBEditJSON() {
		#expect(
			consequencesOf(try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "bbedit")).resultCount)
			== Consequences(1) // swiftformat:disable:this indent
		)
	}

	@Test
	static func parsesSearchResultListFromThingsJSON() {
		#expect(
			consequencesOf(try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "things")).resultCount)
			== Consequences(50) // swiftformat:disable:this indent
		)
	}
}
