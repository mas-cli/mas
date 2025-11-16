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
	func searchesForSlack() async {
		let actual = await consequencesOf(
			try await MAS.main(try MAS.Search.parse(["slack"])) { command in
				try await command.run(searcher: MockAppStoreSearcher(SearchResult(adamID: 1, name: "slack", version: "0.0")))
			}
		)
		let expected = Consequences(nil, "1  slack  (0.0)\n")
		#expect(actual == expected)
	}

	@Test
	func cannotSearchForNonexistentApp() async {
		let searchTerm = "nonexistent"
		let actual = await consequencesOf(
			try await MAS.main(try MAS.Search.parse([searchTerm])) { try await $0.run(searcher: MockAppStoreSearcher()) }
		)
		let expected = Consequences(MASError.noSearchResultsFound(for: searchTerm))
		#expect(actual == expected)
	}
}
