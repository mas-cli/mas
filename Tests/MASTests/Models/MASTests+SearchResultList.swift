//
// MASTests+SearchResultList.swift
// mas
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import Foundation
@testable private import MAS
internal import Testing

@Test
func parsesSearchResultListFromBBEditJSON() {
	#expect(
		consequencesOf(
			try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "search/bbedit.json")).resultCount
		)
		== Consequences(1) // swiftformat:disable:this indent
	)
}

@Test
func parsesSearchResultListFromThingsJSON() {
	#expect(
		consequencesOf(
			try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "search/things.json")).resultCount
		)
		== Consequences(50) // swiftformat:disable:this indent
	)
}
