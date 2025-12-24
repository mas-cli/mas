//
// MASTests+Search.swift
// mas
//
// Copyright © 2018 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func searchesForSlack() {
		let actual = consequencesOf(
			try MAS.main(try MAS.Search.parse(["slack"])) { command in
				try command.run(catalogApps: [CatalogApp(adamID: 1, name: "slack", version: "0.0")])
			},
		)
		let expected = Consequences(nil, "1  slack  (0.0)\n")
		#expect(actual == expected)
	}

	@Test
	func cannotSearchForNonexistentApp() {
		let searchTerm = "nonexistent"
		let actual = consequencesOf(try MAS.main(try MAS.Search.parse([searchTerm])) { try $0.run(catalogApps: []) })
		let expected = Consequences(nil, "", "Error: \(MASError.noCatalogAppsFound(for: searchTerm))\n")
		#expect(actual == expected)
	}
}
