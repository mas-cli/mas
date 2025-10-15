//
// MASTests+Search.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

extension MASTests {
	@Test
	static func searchesForSlack() async {
		let actual = await consequencesOf(
			try await MAS.Search.parse(["slack"]).run(
				searcher: MockAppStoreSearcher(SearchResult(adamID: 1, name: "slack", version: "0.0"))
			)
		)
		let expected = Consequences(nil, "1  slack  (0.0)\n")
		#expect(actual == expected)
	}

	@Test
	static func cannotSearchForNonexistentApp() async {
		let searchTerm = "nonexistent"
		let actual = await consequencesOf(try await MAS.Search.parse([searchTerm]).run(searcher: MockAppStoreSearcher()))
		let expected = Consequences(
			ExitCode(1),
			"",
			"Error: No apps found in the Mac App Store for search term: \(searchTerm)\n"
		)
		#expect(actual == expected)
	}
}
