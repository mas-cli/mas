//
// SearchResultSpec.swift
// masTests
//
// Copyright © 2020 mas-cli. All rights reserved.
//

private import Foundation
@testable private import mas
internal import Testing

@Test
func parsesSearchResultFromThingsThatGoBumpJSON() {
	#expect(
		consequencesOf(
			try JSONDecoder() // swiftformat:disable indent
			.decode(SearchResult.self, from: Data(fromResource: "search/things-that-go-bump.json"))
			.trackId
		) // swiftformat:enable indent
		== ValuedConsequences(1_472_954_003) // swiftformat:disable:this indent
	)
}
