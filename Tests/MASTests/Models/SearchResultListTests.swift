//
// SearchResultListTests.swift
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
		== ValuedConsequences(1) // swiftformat:disable:this indent
	)
}

@Test
func parsesSearchResultListFromThingsJSON() {
	#expect(
		consequencesOf(
			try JSONDecoder().decode(SearchResultList.self, from: Data(fromResource: "search/things.json")).resultCount
		)
		== ValuedConsequences(50) // swiftformat:disable:this indent
	)
}
