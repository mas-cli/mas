//
// SearchResultTests.swift
// mas
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import Foundation
@testable private import MAS
internal import Testing

@Test
func parsesSearchResultFromThingsThatGoBumpJSON() {
	#expect(
		consequencesOf(
			try JSONDecoder().decode(SearchResult.self, from: Data(fromResource: "search/things-that-go-bump.json")).trackId
		)
		== ValuedConsequences(1_472_954_003) // swiftformat:disable:this indent
	)
}
