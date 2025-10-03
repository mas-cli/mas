//
// SearchTests.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import MAS
internal import Testing

@Test
func searchesForSlack() async {
	let result = SearchResult(trackId: 1111, trackName: "slack", trackViewUrl: "mas preview url", version: "0.0")
	#expect(
		await consequencesOf(
			try await MAS.Search.parse(["slack"]).run(
				searcher: MockAppStoreSearcher([.adamID(result.adamID): result])
			)
		)
		== Consequences(nil, "1111  slack  (0.0)\n") // swiftformat:disable:this indent
	)
}

@Test
func cannotSearchForNonexistentApp() async {
	let searchTerm = "nonexistent"
	#expect(
		await consequencesOf(
			try await MAS.Search.parse([searchTerm]).run(searcher: MockAppStoreSearcher())
		) // swiftformat:disable:next indent
		== Consequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for search term: \(searchTerm)\n")
	)
}
